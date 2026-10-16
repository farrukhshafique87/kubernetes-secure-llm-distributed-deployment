#!/usr/bin/env bash
# Install Metrics Server on Kind (needed for `kubectl top` and CPU/memory data).
# Kind kubelets use self-signed certificates, hence --kubelet-insecure-tls.
set -euo pipefail

# Pinned to the version used in the EXP-06 runs (results/exp-06-final/*-environment.txt).
METRICS_SERVER_VERSION="${METRICS_SERVER_VERSION:-v0.9.0}"

kubectl apply -f "https://github.com/kubernetes-sigs/metrics-server/releases/download/${METRICS_SERVER_VERSION}/components.yaml"

if ! kubectl -n kube-system get deploy metrics-server -o jsonpath='{.spec.template.spec.containers[0].args}' \
  | grep -q kubelet-insecure-tls; then
  kubectl -n kube-system patch deployment metrics-server --type=json \
    -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi

kubectl -n kube-system rollout status deploy/metrics-server --timeout=180s
echo "Image in use:"
kubectl -n kube-system get deploy metrics-server -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
echo "Try: kubectl top nodes   (may need ~60 s before data appears)"
