#!/usr/bin/env bash
# Functional checks of the security controls in one namespace.
# Usage: verify-controls.sh <namespace>
# Checks only what is deployed in the namespace (RBAC objects, NetworkPolicies,
# gateway). Exit code 1 if any check fails, 2 if the pods never become Ready.
# A failing check prints the last lines of the command output, so the cause is
# recorded (a check that hides its error cannot be explained afterwards).
set -uo pipefail
NS="${1:?usage: verify-controls.sh <namespace>}"
PASS=0
FAIL=0

# check "<description>" <yes|no> <command...>   (yes = command must succeed)
check() {
  local desc="$1" expected="$2" result out
  shift 2
  if out=$("$@" 2>&1); then result=yes; else result=no; fi
  if [ "$result" = "$expected" ]; then
    echo "PASS  $desc"
    PASS=$((PASS + 1))
  else
    echo "FAIL  $desc (expected $expected, got $result)"
    printf '%s\n' "$out" | tail -n 5 | sed 's/^/      | /'
    FAIL=$((FAIL + 1))
  fi
}

# HTTP GET from inside a pod: fetch <deployment> <url>
fetch() {
  kubectl -n "$NS" exec "deploy/$1" -c "$1" -- python -c \
    "import sys, urllib.request; urllib.request.urlopen(sys.argv[1], timeout=4)" "$2"
}

# Checks right after a rollout can fail only because a pod is not Ready yet.
echo "Waiting for all pods in $NS to be Ready..."
if ! kubectl -n "$NS" wait --for=condition=Ready pod --all --timeout=180s >/dev/null; then
  echo "ERROR: pods in $NS are not Ready; no checks were run."
  kubectl -n "$NS" get pods
  exit 2
fi

token_not_mounted() {
  [ "$(kubectl -n "$NS" get deploy "$1" -o jsonpath='{.spec.template.spec.automountServiceAccountToken}')" = "false" ]
}

if kubectl -n "$NS" get serviceaccount fastapi >/dev/null 2>&1; then
  echo "== RBAC"
  check "fastapi pod has no API token mounted" yes token_not_mounted fastapi
  check "fastapi service account cannot list pods" no \
    kubectl auth can-i list pods -n "$NS" --as="system:serviceaccount:$NS:fastapi"
  check "viewer group can read pods" yes \
    kubectl auth can-i get pods -n "$NS" --as=tester --as-group=llm-viewers
  check "viewer group cannot read secrets" no \
    kubectl auth can-i get secrets -n "$NS" --as=tester --as-group=llm-viewers
  check "viewer group cannot delete deployments" no \
    kubectl auth can-i delete deployments.apps -n "$NS" --as=tester --as-group=llm-viewers
fi

if kubectl -n "$NS" get networkpolicy -o name 2>/dev/null | grep -q .; then
  echo "== NetworkPolicies"
  check "api -> ollama is allowed" yes fetch fastapi http://ollama-service:11434/api/tags
  check "api -> internet is blocked" no fetch fastapi https://example.com
  if kubectl -n "$NS" get deploy gateway >/dev/null 2>&1; then
    check "gateway -> api is allowed" yes fetch gateway http://fastapi-service:8010/health
    check "gateway -> ollama is blocked" no fetch gateway http://ollama-service:11434/api/tags
  fi
fi

has_proxy() {
  local names
  names=$(kubectl -n "$NS" get pods -l "$1" \
    -o jsonpath='{.items[0].spec.containers[*].name} {.items[0].spec.initContainers[*].name}')
  [[ "$names" == *linkerd-proxy* ]]
}

tls_seen() {
  local metrics
  metrics=$(kubectl -n "$NS" exec deploy/fastapi -c fastapi -- curl -s localhost:4191/metrics)
  [[ "$metrics" == *'tls="true"'* ]]
}

mesh_enabled() {
  [ "$(kubectl -n "$NS" get deploy fastapi -o jsonpath='{.spec.template.metadata.annotations.linkerd\.io/inject}')" = "enabled" ]
}

if mesh_enabled; then
  echo "== mTLS (Linkerd)"
  check "api pod runs the Linkerd proxy" yes has_proxy app.kubernetes.io/name=llm-api
  check "ollama pod runs the Linkerd proxy" yes has_proxy app=ollama
  fetch fastapi http://ollama-service:11434/api/tags >/dev/null 2>&1
  check "api -> ollama traffic is mTLS (proxy metrics)" yes tls_seen
fi

echo
echo "passed: $PASS  failed: $FAIL"
[ "$FAIL" -eq 0 ]
