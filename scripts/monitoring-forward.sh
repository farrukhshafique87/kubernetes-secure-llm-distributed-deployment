#!/usr/bin/env bash
# Make Prometheus (localhost:9090) and Grafana (localhost:3000) reachable from
# the WSL host while measurements run. Keep this running in a second terminal;
# stop with Ctrl+C.
#
# k6 runs on the host and pushes its results to Prometheus through this
# forward (MONITOR=1, see scripts/run-experiment.sh). A port-forward can drop,
# for example when a pod restarts, so each one is restarted in a loop.
set -euo pipefail

forward() {
  local svc="$1" port="$2"
  while true; do
    kubectl -n monitoring port-forward "svc/$svc" "$port:$port" >/dev/null 2>&1 || true
    echo "$(date +%H:%M:%S) port-forward $svc:$port stopped, restarting in 2 s" >&2
    sleep 2
  done
}

trap 'kill 0' INT TERM EXIT

forward prometheus 9090 &
forward grafana 3000 &

echo "Prometheus: http://localhost:9090   Grafana: http://localhost:3000 (Ctrl+C to stop)"
wait
