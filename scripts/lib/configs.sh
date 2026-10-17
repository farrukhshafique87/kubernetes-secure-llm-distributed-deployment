# Configuration table and switching, shared by measure-config.sh and measure-load.sh.
# Source from the repository root:  . scripts/lib/configs.sh
# shellcheck shell=bash

ALL_NS="llm-baseline llm-c1-rbac llm-c2-netpol llm-c3-mtls llm-c4-tls llm-c5-gateway llm-secure"

# config_vars <config>: sets OVERLAY, NS, URL and AUTH for a configuration.
config_vars() {
  case "$1" in
    c0-baseline) OVERLAY=kind-baseline;   NS=llm-baseline;   URL=http://localhost:8010;  AUTH=no  ;;
    c1-rbac)     OVERLAY=kind-c1-rbac;    NS=llm-c1-rbac;    URL=http://localhost:8010;  AUTH=no  ;;
    c2-netpol)   OVERLAY=kind-c2-netpol;  NS=llm-c2-netpol;  URL=http://localhost:8010;  AUTH=no  ;;
    c3-mtls)     OVERLAY=kind-c3-mtls;    NS=llm-c3-mtls;    URL=http://localhost:8010;  AUTH=no  ;;
    c4-tls)      OVERLAY=kind-c4-tls;     NS=llm-c4-tls;     URL=https://localhost:8443; AUTH=no  ;;
    c5-gateway)  OVERLAY=kind-c5-gateway; NS=llm-c5-gateway; URL=http://localhost:8010;  AUTH=yes ;;
    c6-all)      OVERLAY=kind-secure;     NS=llm-secure;     URL=https://localhost:8443; AUTH=yes ;;
    *) echo "unknown config: $1" >&2; return 1 ;;
  esac
}

# switch_config <config>: pauses every other environment, starts this one,
# makes sure the model is present and exports BASE_URL, AUTH_TOKEN and
# K6_INSECURE_SKIP_TLS_VERIFY for k6. Leaves NS set for the caller.
switch_config() {
  local config="$1" model="${OLLAMA_MODEL:-qwen2.5:0.5b}" n
  config_vars "$config"

  echo "== switching to $config ($NS)"
  for n in $ALL_NS; do
    if [ "$n" != "$NS" ] && kubectl get ns "$n" >/dev/null 2>&1; then
      ./scripts/pause-env.sh "$n" >/dev/null
    fi
  done

  ./scripts/resume-env.sh "kubernetes/overlays/$OVERLAY" "$NS"

  if ! kubectl -n "$NS" exec deploy/ollama -c ollama -- ollama list | grep -q "$model"; then
    ./scripts/pull-model.sh "$NS" "kubernetes/overlays/$OVERLAY"
  fi

  unset AUTH_TOKEN K6_INSECURE_SKIP_TLS_VERIFY
  export BASE_URL="$URL"
  if [ "$AUTH" = "yes" ]; then
    AUTH_TOKEN="$(grep '^API_KEY=' kubernetes/components/gateway/gateway.env | cut -d= -f2)"
    export AUTH_TOKEN
  fi
  case "$URL" in https://*) export K6_INSECURE_SKIP_TLS_VERIFY=true ;; esac
}
