#!/usr/bin/env bash
# One measured k6 run following docs/research/experiment-methodology.md:
# env record -> smoke -> warm-up -> measured run -> restart check -> cool-down.
#
# Usage: run-experiment.sh <exp-dir> <config> <rep> <namespace> [k6-script]
# Example:
#   ./scripts/run-experiment.sh exp-01-baseline c0-baseline 1 llm-baseline
#
# Env overrides: BASE_URL (default http://localhost:8010), VUS (1),
#   DURATION (5m), WARMUP (1m), COOLDOWN (120), SCRIPT_ARGS
set -euo pipefail

EXP="${1:?usage: run-experiment.sh <exp-dir> <config> <rep> <namespace> [k6-script]}"
CONFIG="${2:?config name, e.g. c0-baseline}"
REP="${3:?repetition number}"
NS="${4:?namespace}"
SCRIPT="${5:-tests/k6/baseline.js}"

BASE_URL="${BASE_URL:-http://localhost:8010}"
VUS="${VUS:-1}"
DURATION="${DURATION:-5m}"
WARMUP="${WARMUP:-1m}"
COOLDOWN="${COOLDOWN:-120}"

cd "$(dirname "$0")/.."
OUT="results/${EXP}"
RUN_ID="${EXP}-${CONFIG}-r${REP}"
mkdir -p "$OUT"

restarts() {
  kubectl -n "$NS" get pods \
    -o jsonpath='{range .items[*]}{.metadata.name}{"="}{.status.containerStatuses[0].restartCount}{"\n"}{end}' | sort
}

# Environment record once per config
if [ ! -f "$OUT/${CONFIG}-environment.txt" ]; then
  ./scripts/record-environment.sh "$OUT/_env" "$NS" >/dev/null
  mv "$OUT/_env/environment.txt" "$OUT/${CONFIG}-environment.txt"
  rmdir "$OUT/_env"
fi

echo "== smoke"
k6 run --quiet -e BASE_URL="$BASE_URL" tests/k6/smoke.js

echo "== warm-up ($WARMUP, discarded)"
k6 run --quiet -e BASE_URL="$BASE_URL" -e VUS="$VUS" -e DURATION="$WARMUP" "$SCRIPT" >/dev/null || true

# Resource sampling (CPU/memory per pod) every 15 s if Metrics Server is installed
SAMPLER_PID=""
if kubectl top pods -n "$NS" >/dev/null 2>&1; then
  (
    NAMESPACES="$NS"
    for extra in traefik linkerd; do
      kubectl get ns "$extra" >/dev/null 2>&1 && NAMESPACES="$NAMESPACES $extra"
    done
    while true; do
      LINE=""
      for n in $NAMESPACES; do
        LINE="$LINE$(kubectl top pods -n "$n" --no-headers 2>/dev/null | tr -s ' ' | tr '\n' ';')"
      done
      echo "$(date -u +%H:%M:%S) $LINE"
      sleep 15
    done
  ) > "$OUT/${CONFIG}-r${REP}.resources.txt" &
  SAMPLER_PID=$!
else
  echo "NOTE: Metrics Server not available - no CPU/memory samples for this run"
fi

BEFORE="$(restarts)"
echo "== measured run: $RUN_ID ($DURATION, $VUS VUs)"
START="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
k6 run -e BASE_URL="$BASE_URL" -e VUS="$VUS" -e DURATION="$DURATION" -e RUN_ID="$RUN_ID" \
  --summary-trend-stats="avg,min,med,max,p(90),p(95),p(99)" \
  --summary-export="$OUT/${CONFIG}-r${REP}.json" "$SCRIPT" || true
END="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
[ -n "$SAMPLER_PID" ] && kill "$SAMPLER_PID" 2>/dev/null || true
AFTER="$(restarts)"

{
  echo "run_id=$RUN_ID"
  echo "start=$START"
  echo "end=$END"
  echo "script=$SCRIPT vus=$VUS rate=${RATE:--} duration=$DURATION base_url=$BASE_URL"
  if [ "$BEFORE" = "$AFTER" ]; then echo "valid=true (no pod restarts during run)"; else
    echo "valid=FALSE (pod restarted during run - discard and repeat)"
    echo "restarts_before:"; echo "$BEFORE"; echo "restarts_after:"; echo "$AFTER"
  fi
} | tee "$OUT/${CONFIG}-r${REP}.meta.txt"

echo "== cool-down ${COOLDOWN}s"
sleep "$COOLDOWN"
