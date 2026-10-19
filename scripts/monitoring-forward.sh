#!/usr/bin/env bash
# Make Prometheus (localhost:9090) and Grafana (localhost:3000) reachable from
# the WSL host while measurements run. Keep this running in a second terminal;
# stop with Ctrl+C.
#
# k6 runs on the host and pushes its results to Prometheus through this
# forward (MONITOR=1, see scripts/run-experiment.sh).
#
# After a restart of Docker Desktop or of the monitoring pods, two things go
# wrong with a plain port-forward: an old forward (from a closed terminal or an
# earlier session) still holds the port, and a forward to a pod that no longer
# exists stays alive but answers nothing. This script therefore stops old
# forwards first, waits for the pods, and restarts a forward when the service
# behind it stops answering.
set -euo pipefail

PATTERN='kubectl -n monitoring port-forward svc/'

# Another copy of this script (in a forgotten terminal) would restart its
# forwards and fight with this one over the ports. The pid file names it.
PIDFILE="${TMPDIR:-/tmp}/monitoring-forward.pid"
if [ -f "$PIDFILE" ]; then
  old="$(cat "$PIDFILE")"
  if kill -0 "$old" 2>/dev/null &&
    tr '\0' ' ' <"/proc/$old/cmdline" | grep -q monitoring-forward; then
    echo "Stopping an earlier monitoring-forward.sh (pid $old)"
    kill "$old" 2>/dev/null || true
    sleep 1
  fi
fi
echo $$ >"$PIDFILE"

if pgrep -f "$PATTERN" >/dev/null; then
  echo "Stopping port-forwards left from an earlier session:"
  pgrep -af "$PATTERN" || true
  pkill -f "$PATTERN" || true
  sleep 1
fi

echo "Waiting for Prometheus and Grafana to be ready ..."
kubectl -n monitoring rollout status deploy/prometheus --timeout=180s
kubectl -n monitoring rollout status deploy/grafana --timeout=180s

# forward <service> <port> <health url>: keeps one port-forward running. Checks
# the service through it every 10 s and restarts the forward after 3 failed
# checks in a row.
forward() {
  local svc="$1" port="$2" url="$3" log pid fails
  log="$(mktemp)"
  while true; do
    kubectl -n monitoring port-forward "svc/$svc" "$port:$port" >"$log" 2>&1 &
    pid=$!
    fails=0
    sleep 2
    while kill -0 "$pid" 2>/dev/null; do
      if curl -fsS -m 3 -o /dev/null "$url" 2>/dev/null; then
        fails=0
      else
        fails=$((fails + 1))
      fi
      if [ "$fails" -ge 3 ]; then
        kill "$pid" 2>/dev/null || true
        break
      fi
      sleep 10
    done
    wait "$pid" 2>/dev/null || true
    echo "$(date +%H:%M:%S) port-forward $svc:$port restarted ($(tail -n 1 "$log"))" >&2
    sleep 2
  done
}

# On Ctrl+C, a closed terminal or kill: stop every forward started here. The
# traps are removed first, otherwise kill 0 would trigger them again.
cleanup() {
  trap - INT TERM HUP EXIT
  rm -f "$PIDFILE"
  kill 0 2>/dev/null || true
}
trap cleanup INT TERM HUP EXIT

forward prometheus 9090 http://localhost:9090/-/ready &
forward grafana 3000 http://localhost:3000/api/health &

echo "Prometheus: http://localhost:9090   Grafana: http://localhost:3000 (Ctrl+C to stop)"
wait
