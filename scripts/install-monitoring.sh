#!/usr/bin/env bash
# Install or update Prometheus and Grafana in the "monitoring" namespace.
# Re-running is safe: existing volumes (measurement data, Grafana database) are kept.
#
# Needs monitoring/grafana/secret.yaml (git-ignored), created from
# secret.example.yaml with a real password.
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f monitoring/grafana/secret.yaml ]; then
  echo "ERROR: monitoring/grafana/secret.yaml is missing." >&2
  echo "  cp monitoring/grafana/secret.example.yaml monitoring/grafana/secret.yaml" >&2
  echo "  then replace CHANGE_ME with a password of your choice." >&2
  exit 1
fi

# Explicit file list: secret.example.yaml must never be applied.
kubectl apply -f monitoring/prometheus/namespace.yaml
kubectl apply \
  -f monitoring/prometheus/serviceaccount.yaml \
  -f monitoring/prometheus/clusterrole.yaml \
  -f monitoring/prometheus/clusterrolebinding.yaml \
  -f monitoring/prometheus/configmap.yaml \
  -f monitoring/prometheus/pvc.yaml \
  -f monitoring/prometheus/deployment.yaml \
  -f monitoring/prometheus/service.yaml \
  -f monitoring/grafana/secret.yaml \
  -f monitoring/grafana/pvc.yaml \
  -f monitoring/grafana/datasources.yaml \
  -f monitoring/grafana/dashboard-provider.yaml \
  -f monitoring/grafana/dashboard-exp-load.yaml \
  -f monitoring/grafana/deployment.yaml \
  -f monitoring/grafana/service.yaml

# ConfigMap changes are only read at start-up.
kubectl -n monitoring rollout restart deploy/prometheus deploy/grafana
kubectl -n monitoring rollout status deploy/prometheus --timeout=180s
kubectl -n monitoring rollout status deploy/grafana --timeout=180s

echo "== versions in use"
kubectl -n monitoring get deploy -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.template.spec.containers[0].image}{"\n"}{end}'
echo "Next: ./scripts/monitoring-forward.sh (keep it running), then open http://localhost:3000"
