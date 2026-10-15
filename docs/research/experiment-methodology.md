# Experiment Methodology

Status: draft.
This document defines how each experiment is run. Results are stored in `results/`.

## 1. Fixed decisions

| Topic            | Decision                                                           |
| ---------------- | ------------------------------------------------------------------ |
| Research Qs      | RQ1 total overhead, RQ2 local vs cloud, RQ3 per-control            |
| Deadline         | December 2026                                                      |
| Model            | Qwen2.5 0.5b via Ollama                                            |
| Inference params | temperature 0.0, seed 42, 64 output tokens, model kept loaded      |
| Configuration    | Kustomize: one base, overlays per environment and security level   |
| Baseline         | `kind-baseline` overlay: no security controls                      |
| Secure           | `kind-secure` overlay: controls added as Kustomize components      |
| Ingress          | Traefik                                                            |
| Gateway          | Own FastAPI gateway pod: API key from a Secret, route allowlist    |
| TLS              | Self-signed EC P-256 certificate, terminated at the ingress        |
| mTLS             | Linkerd edge channel                                               |
| Secure entry     | https://localhost:8443 (k6: K6_INSECURE_SKIP_TLS_VERIFY=true)      |
| Run rule         | Only ONE environment (baseline or secure) runs at a time           |
| CNI              | Calico in all runs (baseline and secure)                           |

## 2. What "baseline" contains

The baseline has no RBAC restrictions beyond defaults, no NetworkPolicies, no
mTLS, no application Secrets and no ingress/authentication gateway. Container
hardening already in the base manifests (non-root user, dropped capabilities)
is part of **every** configuration and is therefore not counted as overhead.

## 3. Controlled variables

Same container images, model and model version, prompt, inference parameters,
Ollama settings (keep-alive, parallelism), resource requests/limits, Kubernetes
and Calico versions, load profile and tool versions. Any change is recorded in
the environment record (`scripts/record-environment.sh`).

## 4. Run protocol

1. Pause the other environment (`make pause-baseline` / `make pause-secure`).
2. Run `scripts/record-environment.sh results/<exp>/ <namespace>`.
3. Run `tests/k6/smoke.js`. Abort if it fails.
4. Warm-up: 1 minute of the same load, discarded.
5. Measured run: 5 minutes, `--summary-export` to `results/<exp>/`.
6. Cool-down 2 minutes. Repeat for at least 3 repetitions (5 if time allows).
7. Interleave configurations (C0, C1, … C0, C1, …) instead of running all
   repetitions of one configuration first, to spread out time-dependent noise.
8. Close other heavy applications on the host during runs.

## 5. Two measurement paths

| Path        | Endpoint  | Why                                                        |
| ----------- | --------- | ---------------------------------------------------------- |
| Full        | `/chat`   | Realistic end-to-end cost including inference              |
| Lightweight | `/health` | No inference: exposes the per-request cost of the controls |

## 6. Analysis

Per configuration: mean of the per-run averages, with the min–max spread over the
repetitions (computed by `scripts/overhead_table.py`). Overhead =
(secured − baseline) / baseline for average latency, P95, P99, CPU and memory.
The spread is reported so that differences inside the noise are not claimed as
overhead. Kind and cloud results are reported separately (RQ2).

## 7. Threats to validity

* Kind nodes are containers on one machine: no real network between nodes, and
  the load generator shares the host CPU.
* CPU-only inference; results do not transfer to GPU serving.
* Overhead of NetworkPolicies is specific to the CNI (Calico).
* Single model, single prompt, small repetition count.
* Cloud node types differ from the laptop, so only the relative overhead will be compared.
* k6 reuses connections, so the TLS handshake cost is spread over many requests;
  handshake cost alone is not measured.
* The lab certificate is self-signed and k6 skips certificate verification, so
  certificate validation cost is not included.
* TLS ends at the ingress; hops behind it are plain HTTP until mTLS (C3) is on.
* The gateway is a Python (FastAPI/httpx) proxy; its overhead reflects this
  implementation, not API gateways in general.
* Linkerd's open-source project publishes edge releases only; the chart and
  proxy versions are recorded in the environment record of each run.

## 8. Configurations and entry points

| Config      | Overlay         | Namespace      | Entry                  | Key |
| ----------- | --------------- | -------------- | ---------------------- | --- |
| c0-baseline | kind-baseline   | llm-baseline   | http://localhost:8010  | no  |
| c1-rbac     | kind-c1-rbac    | llm-c1-rbac    | http://localhost:8010  | no  |
| c2-netpol   | kind-c2-netpol  | llm-c2-netpol  | http://localhost:8010  | no  |
| c3-mtls     | kind-c3-mtls    | llm-c3-mtls    | http://localhost:8010  | no  |
| c4-tls      | kind-c4-tls     | llm-c4-tls     | https://localhost:8443 | no  |
| c5-gateway  | kind-c5-gateway | llm-c5-gateway | http://localhost:8010  | yes |
| c6-all      | kind-secure     | llm-secure     | https://localhost:8443 | yes |

C3 uses Linkerd. Only hops between meshed workloads use mTLS; Traefik is not
meshed, so the hop from the ingress to the gateway is plain HTTP.

Configurations without an
ingress are reached through a NodePort on the Kind control-plane node;
configurations with TLS go through Traefik. The entry path is therefore part of
what each configuration changes.

Each configuration runs in its own namespace with its own model volume. Only one
namespace is active at a time; `scripts/measure-config.sh` pauses the others,
starts the requested one, and runs the `/chat` and `/health` tests. Repetitions
are interleaved by looping over the configurations for each repetition.
