# Project Roadmap

Status as of 2026-10-18. "Done" means the evidence is in this repository.

| # | Milestone | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Development environment and repository structure | Done | [deployment-environment.md](deployment-environment.md), `Makefile` |
| 2 | FastAPI service, Docker image, unit tests | Done | `apps/llm-api`, `apps/llm-gateway`, tests run in CI |
| 3 | Kubernetes deployment with Kustomize, Ollama | Done | `kubernetes/base`, `kubernetes/overlays` |
| 4 | Ingress controller (Traefik) and TLS | Done | `kubernetes/components/ingress-tls`, `scripts/install-ingress.sh` |
| 5 | Monitoring with Prometheus and Grafana | Done | `monitoring/`, [monitoring.md](monitoring.md): live k6 metrics, container CPU and throttling, provisioned dashboard, persistent volumes |
| 6 | Security: RBAC, NetworkPolicies, Secrets, mTLS, API gateway | Done | `kubernetes/components/`, EXP-05 in `results/exp-05-security-verification/` |
| 7 | Performance experiments with k6 on Kind | Done | EXP-01 and EXP-06 in `results/` |
| 8 | GitHub Actions CI | Done | `.github/workflows/ci.yml`: lint, tests, manifest validation, image build |
| 9 | Sensitivity experiments: load, replicas, resource limits (EXP-02 to EXP-04) | In progress | EXP-02 done: `results/exp-02-load/`, methodology §9.6; EXP-03 and EXP-04 planned |
| 10 | Managed cloud deployment and comparison with Kind (EXP-07) | Planned | `docs/research/research-traceability-matrix.md` |
| 11 | Thesis analysis and write-up | In progress | thesis document (not in this repository) |

Helm is used to install third-party components (Traefik, Linkerd). The application
itself is deployed with Kustomize.
