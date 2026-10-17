# Monitoring: Prometheus and Grafana

Prometheus and Grafana run in the `monitoring` namespace of the Kind cluster.
They are used to watch load runs while they happen and to see where CPU runs out.
All numbers in the thesis come from the k6 summary files in `results/`; the
monitoring data explains them but does not replace them.

## What is collected

| Source | How it reaches Prometheus | Used for |
| --- | --- | --- |
| k6 (request rate, latency, failed requests, dropped iterations, VUs) | k6 pushes every 5 s (`-o experimental-prometheus-rw`), tagged with `testid` = run id | Live view of a run, comparison of runs |
| Kubelet cAdvisor of every node | Prometheus scrapes it through the API server proxy (`monitoring/prometheus/clusterrole.yaml`) | CPU per container, **CPU throttling**, memory |
| FastAPI `/metrics` | Prometheus scrapes the service | Application metrics |

CPU throttling is the share of scheduler periods (100 ms each) in which a
container could not run because it had used its CPU limit. `kubectl top` cannot
show it, and it reports CPU per pod, so the Linkerd proxy is mixed into the
gateway pod's value. cAdvisor reports both per container.

## Persistence

| What | Where it is kept | Survives |
| --- | --- | --- |
| Measurement data | `prometheus-pvc` (10 Gi), retention 120 days or 8 GB | Pod restarts, Docker Desktop restarts |
| Data source and dashboard | ConfigMaps in `monitoring/grafana/`, provisioned at start-up | Everything, including a new cluster (they are in git) |
| Grafana users and settings | `grafana-pvc` (1 Gi) | Pod restarts, Docker Desktop restarts |

The volumes live inside the Kind node containers, so `kind delete cluster`
removes the measurement data. The k6 summary files in `results/` are not affected.

## Use

```bash
cp monitoring/grafana/secret.example.yaml monitoring/grafana/secret.yaml   # once; set a password
./scripts/install-monitoring.sh

# Second terminal, keep it open during measurements:
./scripts/monitoring-forward.sh

# Measurements with live data:
MONITOR=1 ./scripts/measure-load.sh c6-all 1
```

Grafana: <http://localhost:3000>, folder "Thesis", dashboard
"Load runs: k6 and containers". Select runs with the "Run" variable
(`<exp>-<config>-r<rep>`; warm-ups end in `-warmup`).

## Rules for experiments

- `MONITOR=1` makes k6 push its metrics, which costs some CPU on the host that
  also runs the cluster. Use the same `MONITOR` value for every run of one
  experiment. Each run records it in its `.meta.txt` (`monitor=0` or `monitor=1`).
- Prometheus and Grafana run during all runs of an experiment, whether `MONITOR`
  is 0 or 1, so their own CPU use is the same for every configuration.
- If `MONITOR=1` and Prometheus cannot be reached, `run-experiment.sh` stops
  before the run starts instead of producing a run without live data.
