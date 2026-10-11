### Lightweight path (/health), no inference

| Config | Avg ms | Δ ms | Δ % | P95 ms | P99 ms | Runs | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- |
| c0-baseline | 1.95 (1.89-2.02) | - | - | 2.57 | 3.15 | 3 | reference |
| c1-rbac | 1.97 (1.93-2.03) | +0.03 | +1.3 | 2.61 | 3.30 | 3 | within noise |
| c2-netpol | 1.93 (1.88-2.01) | -0.01 | -0.6 | 2.55 | 3.23 | 3 | within noise |
| c3-mtls | 2.31 (2.24-2.38) | +0.36 | +18.6 | 2.99 | 3.89 | 3 | distinct, higher |
| c4-tls | 2.70 (2.65-2.76) | +0.75 | +38.6 | 3.37 | 4.29 | 3 | distinct, higher |
| c5-gateway | 4.36 (4.32-4.44) | +2.42 | +124.2 | 5.54 | 7.50 | 3 | distinct, higher |
| c6-all | 6.94 (6.34-8.07) | +4.99 | +256.7 | 8.93 | 11.82 | 3 | distinct, higher |
A configuration marked "distinct, lower" is faster than the baseline, which cannot be a cost of the control. It shows drift between runs, not overhead.

### Inference path (/chat)

| Config | Avg ms | Δ ms | Δ % | P95 ms | P99 ms | Runs | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- |
| c0-baseline | 2146.38 (2021.21-2316.47) | - | - | 2422.84 | 2691.04 | 3 | reference |
| c1-rbac | 2013.77 (1975.77-2088.69) | -132.62 | -6.2 | 2165.50 | 2242.65 | 3 | within noise |
| c2-netpol | 2023.60 (1982.51-2074.37) | -122.78 | -5.7 | 2168.23 | 2263.48 | 3 | within noise |
| c3-mtls | 1914.69 (1827.93-2004.16) | -231.70 | -10.8 | 2012.70 | 2121.53 | 3 | distinct, lower |
| c4-tls | 2018.81 (1995.86-2062.44) | -127.57 | -5.9 | 2190.46 | 2358.17 | 3 | within noise |
| c5-gateway | 2059.76 (2025.81-2111.31) | -86.63 | -4.0 | 2303.58 | 3075.00 | 3 | within noise |
| c6-all | 1971.14 (1950.23-1985.36) | -175.25 | -8.2 | 2076.67 | 2169.27 | 3 | distinct, lower |
A configuration marked "distinct, lower" is faster than the baseline, which cannot be a cost of the control. It shows drift between runs, not overhead.

### Resources on the /health path (50 requests/s)

CPU in millicores, memory in MiB; mean over repetitions of the per-run mean.
Only pods that take part in the request path are summed; Linkerd's control
plane counts for the configurations that use the mesh.

| Config | Pods summed | CPU m | Δ CPU m | Memory Mi | Δ Memory Mi |
| --- | --- | --- | --- | --- | --- |
| c0-baseline | fastapi | 86 | - | 46 | - |
| c1-rbac | fastapi | 86 | +0 | 45 | -1 |
| c2-netpol | fastapi | 86 | -1 | 45 | -0 |
| c3-mtls | fastapi, l5d-destination, l5d-identity, l5d-proxy-injector | 113 | +26 | 161 | +115 |
| c4-tls | fastapi, traefik | 130 | +44 | 149 | +104 |
| c5-gateway | fastapi, gateway | 220 | +134 | 92 | +47 |
| c6-all | fastapi, gateway, traefik, l5d-destination, l5d-identity, l5d-proxy-injector | 365 | +279 | 309 | +264 |

