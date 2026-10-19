#!/usr/bin/env python3
"""EXP-02 figures from the k6 summary files.

Usage (needs matplotlib, e.g. in the repository venv):
    python3 scripts/plot_load.py results/exp-02-load

Writes into the same folder:
    fig-overhead-median.png   median /health overhead against the baseline per
                              request rate (runs without collapse, post-hoc view
                              of methodology 9.6), one dot per run, line through
                              the median of the runs
    fig-collapsed-runs.png    number of collapsed runs (of 3) per request rate

The numbers are the same as in load-summary.md (scripts/load_table.py).
"""

import statistics
import sys
import textwrap
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
from load_table import BASE, classify, load  # noqa: E402
from overhead_table import stat  # noqa: E402

# One colour per configuration, the same in every figure (categorical slots 1-3,
# checked for colour-vision deficiency). Markers differ too, so colour is never
# the only cue.
STYLE = {
    "c0-baseline": {"color": "#2a78d6", "marker": "o", "label": "c0 baseline"},
    "c5-gateway": {"color": "#eb6834", "marker": "s", "label": "c5 gateway"},
    "c6-all": {"color": "#1baf7a", "marker": "D", "label": "c6 all controls"},
}
INK = "#2b2b29"
MUTED = "#6b6a63"
GRID = "#e4e3de"
SURFACE = "#fcfcfb"


def style_axes(ax) -> None:
    ax.set_facecolor(SURFACE)
    for side in ("top", "right"):
        ax.spines[side].set_visible(False)
    for side in ("left", "bottom"):
        ax.spines[side].set_color(MUTED)
    ax.tick_params(colors=MUTED, labelcolor=INK)
    ax.grid(axis="y", color=GRID, linewidth=0.8)
    ax.set_axisbelow(True)


def note(ax, text: str) -> None:
    """Small explanatory note, placed 8 pt under the x-axis label."""
    ax.annotate(
        textwrap.fill(text, 105),
        xy=(0, 0),
        xycoords=("axes fraction", ax.xaxis.label),
        xytext=(0, -8),
        textcoords="offset points",
        va="top",
        color=MUTED,
        fontsize=8,
    )


def legend_above(ax) -> None:
    """Legend in one row between the title and the plot area, so it can never
    cover data, reference lines or labels inside the axes."""
    ax.legend(
        frameon=False,
        loc="lower left",
        bbox_to_anchor=(0, 1.0),
        ncol=3,
        borderaxespad=0.2,
        labelcolor=INK,
        fontsize=9,
    )


def _overlap(a, b, gap: float = 4) -> bool:
    """True when two boxes (pixels) are closer than gap pixels."""
    return (
        a.x0 < b.x1 + gap
        and b.x0 < a.x1 + gap
        and a.y0 < b.y1 + gap
        and b.y0 < a.y1 + gap
    )


def check_layout(fig, ax) -> None:
    """Stops with an error when the legend or a text label covers a data point,
    a line (including the zero line), a bar or another label. Runs before
    saving, so a figure with collisions is never written."""
    fig.canvas.draw()
    renderer = fig.canvas.get_renderer()
    boxes = [
        (f"label '{t.get_text()}'", t.get_window_extent(renderer))
        for t in ax.texts
        if t.get_text()
    ]
    if ax.get_legend() is not None:
        boxes.append(("legend", ax.get_legend().get_window_extent(renderer)))
    boxes.append(("x-axis label", ax.xaxis.label.get_window_extent(renderer)))
    boxes.append(("title", ax.title.get_window_extent(renderer)))

    points = []
    for line in ax.get_lines():
        xy = line.get_transform().transform(line.get_xydata())
        for (x0, y0), (x1, y1) in zip(xy, xy[1:], strict=False):
            points += [
                (x0 + (x1 - x0) * i / 40, y0 + (y1 - y0) * i / 40) for i in range(41)
            ]
    for coll in ax.collections:
        points += list(coll.get_offset_transform().transform(coll.get_offsets()))
    bars = [p.get_window_extent(renderer) for p in ax.patches if p.get_height()]

    problems = []
    for name, box in boxes:
        if any(box.contains(x, y) for x, y in points):
            problems.append(f"{name} covers a data point or line")
        if any(_overlap(box, bar) for bar in bars):
            problems.append(f"{name} overlaps a bar")
    for i, (n1, b1) in enumerate(boxes):
        for n2, b2 in boxes[i + 1 :]:
            if _overlap(b1, b2):
                problems.append(f"{n1} overlaps {n2}")
    if problems:
        sys.exit("layout check failed:\n  " + "\n  ".join(problems))


def save(fig, ax, out: Path) -> None:
    fig.tight_layout()
    check_layout(fig, ax)
    fig.savefig(out, facecolor=SURFACE, bbox_inches="tight", pad_inches=0.2)
    plt.close(fig)


def health_runs(runs: dict) -> dict:
    """{(config, rate): [(class, median_ms), ...]} for the /health runs."""
    out = {}
    for (config, path, rate), rs in runs.items():
        if path == "health":
            out[(config, rate)] = [
                (classify(r, float(rate)), stat(r["data"], "http_req_duration", "med"))
                for r in rs
            ]
    return out


def overhead_figure(h: dict, rates: list[int], out: Path) -> None:
    fig, ax = plt.subplots(figsize=(7.2, 4.2), dpi=150)
    fig.patch.set_facecolor(SURFACE)
    style_axes(ax)
    for config in ("c5-gateway", "c6-all"):
        s = STYLE[config]
        xs, ys = [], []
        for rate in rates:
            base = [m for c, m in h.get((BASE, rate), []) if c != "collapse"]
            runs = [m for c, m in h.get((config, rate), []) if c != "collapse"]
            if len(base) < 2 or len(runs) < 2:
                continue
            b = statistics.median(base)
            ax.scatter(
                [rate] * len(runs),
                [m - b for m in runs],
                s=18,
                color=s["color"],
                alpha=0.45,
                linewidths=0,
                zorder=2,
            )
            xs.append(rate)
            ys.append(statistics.median(runs) - b)
        ax.plot(
            xs,
            ys,
            color=s["color"],
            marker=s["marker"],
            markersize=7,
            linewidth=2,
            markeredgecolor=SURFACE,
            markeredgewidth=1.5,
            label=s["label"],
            zorder=3,
        )
        ax.annotate(
            f"{s['label']}  {ys[-1]:+.1f} ms",
            xy=(xs[-1], ys[-1]),
            xytext=(8, 0),
            textcoords="offset points",
            va="center",
            color=INK,
            fontsize=9,
        )
    ax.axhline(0, color=MUTED, linewidth=1)
    ax.set_xlim(rates[0] - 5, rates[-1] + 32)
    ax.set_ylim(-0.5, max(8.0, ax.get_ylim()[1]))
    ax.set_xticks(rates)
    ax.set_xlabel("Request rate on /health (req/s)", color=INK)
    ax.set_ylabel("Median latency over baseline (ms)", color=INK)
    ax.set_title(
        "Overhead per request stays flat until the gateway saturates",
        loc="left",
        color=INK,
        fontsize=11,
        pad=24,
    )
    note(
        ax,
        "Line: median of runs without collapse; dots: single runs. Missing points: "
        "fewer than 2 runs without collapse. Kind, 3 repetitions.",
    )
    legend_above(ax)
    save(fig, ax, out)


def collapse_figure(h: dict, rates: list[int], out: Path) -> None:
    configs = [c for c in STYLE if any(k[0] == c for k in h)]
    fig, ax = plt.subplots(figsize=(7.2, 4.2), dpi=150)
    fig.patch.set_facecolor(SURFACE)
    style_axes(ax)
    width = 0.8 / len(configs)
    for i, config in enumerate(configs):
        s = STYLE[config]
        xs, ys = [], []
        for j, rate in enumerate(rates):
            runs = h.get((config, rate))
            if runs is None:
                continue
            xs.append(j + (i - (len(configs) - 1) / 2) * width)
            ys.append(sum(1 for c, _ in runs if c == "collapse"))
        bars = ax.bar(
            xs,
            ys,
            width=width * 0.9,
            color=s["color"],
            edgecolor=SURFACE,
            linewidth=1,
            label=s["label"],
            zorder=2,
        )
        for bar, y in zip(bars, ys, strict=True):
            ax.text(
                bar.get_x() + bar.get_width() / 2,
                y + 0.05,
                str(y),
                ha="center",
                va="bottom",
                color=INK if y else MUTED,
                fontsize=8,
            )
    ax.set_xticks(range(len(rates)), [str(r) for r in rates])
    ax.set_yticks([0, 1, 2, 3])
    ax.set_ylim(0, 3.4)
    ax.set_xlabel("Request rate on /health (req/s)", color=INK)
    ax.set_ylabel("Collapsed runs (of 3)", color=INK)
    ax.set_title(
        "Only the gateway configurations collapse, from 70 req/s",
        loc="left",
        color=INK,
        fontsize=11,
        pad=24,
    )
    note(
        ax,
        "Collapse: achieved rate < 95 % of target, > 1 % failed or >= 1 % dropped "
        "(methodology 9.6). c5 and c6 were not run at 150 and 200 req/s.",
    )
    legend_above(ax)
    save(fig, ax, out)


def main() -> None:
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    directory = Path(sys.argv[1])
    h = health_runs(load(directory))
    gateway_rates = sorted({r for c, r in h if c != BASE})
    all_rates = sorted({r for _, r in h})
    overhead_figure(h, gateway_rates, directory / "fig-overhead-median.png")
    collapse_figure(h, all_rates, directory / "fig-collapsed-runs.png")
    print(f"wrote {directory}/fig-overhead-median.png and fig-collapsed-runs.png")


if __name__ == "__main__":
    main()
