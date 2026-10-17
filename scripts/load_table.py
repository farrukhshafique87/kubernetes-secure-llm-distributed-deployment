#!/usr/bin/env python3
"""EXP-02 load sweep tables: latency, achieved rate and CPU per load level.

Usage:
    python3 scripts/load_table.py results/exp-02-load [--csv out.csv]

Reads the files written by measure-load.sh:
    <config>-health-rate<R>-r<N>.json   /health at R requests per second
    <config>-chat-vus<V>-r<N>.json      /chat with V virtual users

A /health level is marked "saturated" when the system no longer keeps up with
the requested rate: achieved rate below 95 % of the target, any dropped
iterations, or more than 1 % failed requests. Saturated levels get no
overhead value in the overhead table.
"""

import csv
import json
import re
import statistics
import sys
from collections import defaultdict
from pathlib import Path

from overhead_table import PATH_PODS, pod_cpu_mem, stat, verdict

RUN_FILE = re.compile(
    r"^(?P<config>c\d-[a-z]+)-(?P<path>health|chat)-(?P<kind>rate|vus)"
    r"(?P<level>\d+)-r(?P<rep>\d+)\.json$"
)
BASE = "c0-baseline"
# Pods whose CPU is shown per level; their CPU limits are in the manifests.
DETAIL_PODS = ["fastapi", "gateway", "traefik"]


def load(directory: Path) -> dict[tuple[str, str, int], list[dict]]:
    runs: dict[tuple[str, str, int], list[dict]] = defaultdict(list)
    for path in sorted(directory.glob("*.json")):
        m = RUN_FILE.match(path.name)
        if m:
            key = (m["config"], m["path"], int(m["level"]))
            runs[key].append({"path": path, "data": json.loads(path.read_text())})
    return runs


def metric(runs: list[dict], name: str, field: str, default=None) -> list[float]:
    out = []
    for r in runs:
        v = stat(r["data"], name, field)
        if v is None:
            v = default
        if v is not None:
            out.append(v)
    return out


def mean(xs: list[float]) -> float | None:
    return statistics.mean(xs) if xs else None


def fmt(x: float | None, digits: int = 2) -> str:
    return "-" if x is None else f"{x:.{digits}f}"


def summarise(runs: list[dict], target: float | None) -> dict:
    avg = metric(runs, "http_req_duration", "avg")
    achieved = metric(runs, "http_reqs", "rate")
    failed = metric(runs, "http_req_failed", "value", 0.0)
    dropped = metric(runs, "dropped_iterations", "count", 0.0)
    usage = pod_cpu_mem(runs)
    row = {
        "runs": len(runs),
        "avg": mean(avg),
        "avg_min": min(avg) if avg else None,
        "avg_max": max(avg) if avg else None,
        "avg_list": avg,
        "p95": mean(metric(runs, "http_req_duration", "p(95)")),
        "p99": mean(metric(runs, "http_req_duration", "p(99)")),
        "achieved": mean(achieved),
        "failed_pct": (mean(failed) or 0.0) * 100,
        "dropped": sum(dropped),
        "tps": mean(metric(runs, "llm_tokens_per_second", "avg")),
        "pod_cpu": {p: usage.get(p, (None, None))[0] for p in DETAIL_PODS},
    }
    if target is not None:
        saturated = (
            (row["achieved"] or 0) < 0.95 * target
            or row["dropped"] > 0
            or row["failed_pct"] > 1
        )
        row["status"] = "saturated" if saturated else "ok"
    return row


def table(header: list[str], rows: list[list[str]]) -> None:
    print("| " + " | ".join(header) + " |")
    print("| " + " | ".join("---" for _ in header) + " |")
    for r in rows:
        print("| " + " | ".join(r) + " |")
    print()


def main() -> None:
    args = sys.argv[1:]
    if not args:
        sys.exit(__doc__)
    directory = Path(args[0])
    csv_path = Path(args[args.index("--csv") + 1]) if "--csv" in args else None
    runs = load(directory)
    configs = [c for c in PATH_PODS if any(k[0] == c for k in runs)]
    summary: dict[tuple[str, str, int], dict] = {}
    for key, rs in runs.items():
        summary[key] = summarise(rs, float(key[2]) if key[1] == "health" else None)

    rates = sorted({k[2] for k in runs if k[1] == "health"})
    vus = sorted({k[2] for k in runs if k[1] == "chat"})

    if rates:
        print("### /health latency per request rate\n")
        rows = []
        for c in configs:
            for r in rates:
                s = summary.get((c, "health", r))
                if not s:
                    continue
                spread = f"{fmt(s['avg'])} ({fmt(s['avg_min'])}-{fmt(s['avg_max'])})"
                rows.append(
                    [
                        c,
                        str(r),
                        fmt(s["achieved"], 1),
                        spread,
                        fmt(s["p95"]),
                        fmt(s["p99"]),
                        fmt(s["failed_pct"], 2),
                        f"{s['dropped']:.0f}",
                        str(s["runs"]),
                        s["status"],
                    ]
                )
        table(
            [
                "Config",
                "Target req/s",
                "Achieved req/s",
                "Avg ms",
                "P95 ms",
                "P99 ms",
                "Failed %",
                "Dropped",
                "Runs",
                "Status",
            ],
            rows,
        )

        print("### /health overhead against the baseline at each rate\n")
        others = [c for c in configs if c != BASE]
        rows = []
        for r in rates:
            b = summary.get((BASE, "health", r))
            cells = [str(r), fmt(b["avg"]) if b else "-"]
            for c in others:
                s = summary.get((c, "health", r))
                if not (b and s):
                    cells.append("-")
                    continue
                if "saturated" in (b["status"], s["status"]):
                    # Methodology section 9.3: latency of a saturated level measures
                    # queueing, not the cost of a control.
                    cells.append("n/a (saturated)")
                    continue
                d = s["avg"] - b["avg"]
                cells.append(f"{d:+.2f} ({verdict(b['avg_list'], s['avg_list'])})")
            rows.append(cells)
        table(["Rate req/s", "Baseline avg ms"] + [f"Δ {c} ms" for c in others], rows)

        print("### CPU per pod on the /health path (millicores, mean of run means)\n")
        print(
            "CPU limits in the manifests: fastapi 1000 m, gateway 500 m, "
            "traefik none. A pod at its limit is throttled by the kernel.\n"
            "Pods that are not on the request path of a configuration show '-'.\n"
        )
        rows = []
        for c in configs:
            for r in rates:
                s = summary.get((c, "health", r))
                if s:
                    cpu = [
                        fmt(s["pod_cpu"][p], 0) if p in PATH_PODS[c] else "-"
                        for p in DETAIL_PODS
                    ]
                    rows.append([c, str(r)] + cpu)
        table(["Config", "Rate req/s"] + [f"{p} m" for p in DETAIL_PODS], rows)

    if vus:
        print("### /chat per number of virtual users\n")
        rows = []
        for c in configs:
            for v in vus:
                s = summary.get((c, "chat", v))
                if not s:
                    continue
                spread = f"{fmt(s['avg'])} ({fmt(s['avg_min'])}-{fmt(s['avg_max'])})"
                rows.append(
                    [
                        c,
                        str(v),
                        fmt(s["achieved"], 3),
                        spread,
                        fmt(s["p95"]),
                        fmt(s["p99"]),
                        fmt(s["failed_pct"], 2),
                        fmt(s["tps"], 1),
                        str(s["runs"]),
                    ]
                )
        table(
            [
                "Config",
                "VUs",
                "Throughput req/s",
                "Avg ms",
                "P95 ms",
                "P99 ms",
                "Failed %",
                "Tokens/s",
                "Runs",
            ],
            rows,
        )

    if csv_path:
        with csv_path.open("w", newline="") as f:
            w = csv.writer(f)
            w.writerow(
                [
                    "config",
                    "path",
                    "level",
                    "runs",
                    "avg_ms",
                    "avg_min_ms",
                    "avg_max_ms",
                    "p95_ms",
                    "p99_ms",
                    "achieved_rps",
                    "failed_pct",
                    "dropped",
                    "tokens_per_s",
                ]
                + [f"cpu_{p}_m" for p in DETAIL_PODS]
            )
            for (c, p, lvl), s in sorted(summary.items()):
                w.writerow(
                    [
                        c,
                        p,
                        lvl,
                        s["runs"],
                        s["avg"],
                        s["avg_min"],
                        s["avg_max"],
                        s["p95"],
                        s["p99"],
                        s["achieved"],
                        s["failed_pct"],
                        s["dropped"],
                        s["tps"],
                    ]
                    + [s["pod_cpu"][q] for q in DETAIL_PODS]
                )


if __name__ == "__main__":
    main()
