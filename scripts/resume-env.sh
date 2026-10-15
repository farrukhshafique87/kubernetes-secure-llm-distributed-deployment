#!/usr/bin/env bash
# Start an environment again. Usage: resume-env.sh <overlay-dir> <namespace>
# Re-applies the overlay (restores Ingress and replicas) and waits for the pods.
set -euo pipefail
OVERLAY="${1:?usage: resume-env.sh <overlay-dir> <namespace>}"
NS="${2:?usage: resume-env.sh <overlay-dir> <namespace>}"

# A NodePort can only be used by one service in the whole cluster. If another
# (paused) environment still holds a port this overlay needs, apply would fail
# halfway. Stop before changing anything instead.
for port in $(kubectl kustomize "$OVERLAY" | awk '/nodePort:/ {print $2}'); do
  holder=$(kubectl get svc -A -o jsonpath='{range .items[?(@.spec.type=="NodePort")]}{.metadata.namespace}{" "}{.spec.ports[*].nodePort}{"\n"}{end}' \
    | awk -v p="$port" -v ns="$NS" '$1 != ns { for (i = 2; i <= NF; i++) if ($i == p) print $1 }')
  if [ -n "$holder" ]; then
    echo "ERROR: NodePort $port is already used in namespace(s): $holder"
    echo "Pause that environment first: ./scripts/pause-env.sh <namespace>"
    exit 1
  fi
done

kubectl apply -k "$OVERLAY"
kubectl -n "$NS" scale deploy --all --replicas=1
kubectl -n "$NS" rollout status deploy/ollama --timeout=300s
kubectl -n "$NS" rollout status deploy/fastapi --timeout=300s
if kubectl -n "$NS" get deploy gateway >/dev/null 2>&1; then
  kubectl -n "$NS" rollout status deploy/gateway --timeout=300s
fi
