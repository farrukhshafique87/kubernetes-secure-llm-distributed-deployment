# Experiment results

Raw output of every experiment run, kept unchanged as evidence.
The overhead tables come from [`exp-06-final/overhead-summary.md`](exp-06-final/overhead-summary.md).

## Folders

| Folder | Contents | Status |
| --- | --- | --- |
| `exp-01-baseline` | EXP-01: baseline (c0), 3 runs on `/chat` and 3 on `/health` | Final |
| `exp-05-security-verification` | EXP-05: evidence that each control works (RBAC, NetworkPolicy, mTLS, all controls) | Final |
| `exp-06-final` | EXP-06: 7 configurations x 3 repetitions, interleaved. Source of the overhead tables | Final |
| `exp-06-security-overhead` |  Preliminary runs of TLS + gateway combined (`c45-tls-gateway`), before the one-control-at-a-time design | Preliminary, not used for conclusions |
| `exp-06-trial` |  Trial runs of `c2-netpol` and `c3-mtls` to test the measurement scripts | Trial, not used for conclusions |

## Files per run

| File | Contents |
| --- | --- |
| `<config>-r<N>.json` | k6 summary for `/chat` (checks, latency, request rate) |
| `<config>-health-r<N>.json` | k6 summary for `/health` |
| `*.meta.txt` | Run ID, start and end time, k6 script, VUs, duration, validity (no pod restarts) |
| `*.resources.txt` | CPU (millicores) and memory per pod, sampled during the run |
| `*-environment.txt` | Host, CPU cores, memory and tool versions at run time |

## Environment (exp-06-final)

Windows 11 + WSL2, 8 CPU cores, 10 GiB memory for WSL, Docker 29.6.2, Kind cluster.
Exact details are recorded in each `*-environment.txt`.