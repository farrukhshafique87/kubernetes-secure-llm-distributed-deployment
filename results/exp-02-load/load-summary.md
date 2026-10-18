### /health latency per request rate

| Config | Target req/s | Achieved req/s | Avg ms | P95 ms | P99 ms | Failed % | Dropped | Runs | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| c0-baseline | 50 | 50.0 | 2.25 (2.06-2.49) | 3.27 | 4.71 | 0.00 | 0 | 3 | ok |
| c0-baseline | 60 | 60.0 | 2.26 (2.06-2.39) | 3.33 | 4.73 | 0.00 | 0 | 3 | ok |
| c0-baseline | 70 | 70.0 | 2.20 (2.04-2.39) | 3.19 | 4.78 | 0.00 | 0 | 3 | ok |
| c0-baseline | 80 | 80.0 | 2.23 (2.09-2.40) | 3.29 | 4.84 | 0.00 | 0 | 3 | ok |
| c0-baseline | 90 | 90.0 | 2.27 (2.09-2.42) | 3.42 | 5.38 | 0.00 | 0 | 3 | ok |
| c0-baseline | 100 | 100.0 | 2.30 (2.05-2.65) | 3.35 | 5.31 | 0.00 | 0 | 3 | ok |
| c0-baseline | 150 | 149.9 | 9.63 (2.07-23.51) | 16.68 | 198.55 | 0.00 | 51 | 3 | saturated |
| c0-baseline | 200 | 200.0 | 2.89 (2.14-4.22) | 5.22 | 19.72 | 0.00 | 0 | 3 | ok |
| c5-gateway | 50 | 49.9 | 20.85 (4.67-51.01) | 37.16 | 539.75 | 0.00 | 47 | 3 | saturated |
| c5-gateway | 60 | 60.0 | 5.57 (4.55-6.79) | 7.96 | 10.75 | 0.00 | 0 | 3 | ok |
| c5-gateway | 70 | 68.6 | 101.74 (5.35-293.66) | 613.00 | 1910.85 | 0.00 | 503 | 3 | saturated |
| c5-gateway | 80 | 80.0 | 6.92 (4.76-9.36) | 10.75 | 46.50 | 0.00 | 0 | 3 | ok |
| c5-gateway | 90 | 90.0 | 13.38 (4.84-25.49) | 52.27 | 160.16 | 0.00 | 0 | 3 | ok |
| c5-gateway | 100 | 95.7 | 349.60 (11.25-951.53) | 959.91 | 1906.69 | 0.00 | 1451 | 3 | saturated |
| c6-all | 50 | 50.0 | 8.55 (7.59-9.80) | 12.48 | 18.93 | 0.00 | 0 | 3 | ok |
| c6-all | 60 | 60.0 | 12.90 (7.79-22.15) | 18.51 | 162.18 | 0.00 | 3 | 3 | saturated |
| c6-all | 70 | 70.0 | 27.59 (7.89-51.35) | 105.02 | 495.30 | 0.00 | 18 | 3 | saturated |
| c6-all | 80 | 79.9 | 33.41 (7.89-78.80) | 167.61 | 478.57 | 0.00 | 23 | 3 | saturated |
| c6-all | 90 | 88.0 | 285.46 (8.94-835.19) | 940.22 | 1676.16 | 0.00 | 640 | 3 | saturated |
| c6-all | 100 | 91.9 | 614.72 (9.03-1508.03) | 1831.47 | 3445.23 | 0.00 | 2850 | 3 | saturated |

### /health overhead against the baseline at each rate

| Rate req/s | Baseline avg ms | Δ c5-gateway ms | Δ c6-all ms |
| --- | --- | --- | --- |
| 50 | 2.25 | n/a (saturated) | +6.31 (distinct, higher) |
| 60 | 2.26 | +3.32 (distinct, higher) | n/a (saturated) |
| 70 | 2.20 | n/a (saturated) | n/a (saturated) |
| 80 | 2.23 | +4.68 (distinct, higher) | n/a (saturated) |
| 90 | 2.27 | +11.11 (distinct, higher) | n/a (saturated) |
| 100 | 2.30 | n/a (saturated) | n/a (saturated) |
| 150 | 9.63 | - | - |
| 200 | 2.89 | - | - |

### /health runs per level (post-hoc, methodology 9.6)

| Config | Rate req/s | Stable | Transient | Collapse | Median ms (runs without collapse) |
| --- | --- | --- | --- | --- | --- |
| c0-baseline | 50 | 3 | 0 | 0 | 1.98 |
| c0-baseline | 60 | 3 | 0 | 0 | 2.08 |
| c0-baseline | 70 | 3 | 0 | 0 | 1.99 |
| c0-baseline | 80 | 3 | 0 | 0 | 2.01 |
| c0-baseline | 90 | 3 | 0 | 0 | 2.02 |
| c0-baseline | 100 | 3 | 0 | 0 | 1.96 |
| c0-baseline | 150 | 2 | 1 | 0 | 1.99 |
| c0-baseline | 200 | 3 | 0 | 0 | 1.90 |
| c5-gateway | 50 | 2 | 1 | 0 | 5.37 |
| c5-gateway | 60 | 3 | 0 | 0 | 4.89 |
| c5-gateway | 70 | 2 | 0 | 1 | 4.65 |
| c5-gateway | 80 | 3 | 0 | 0 | 5.27 |
| c5-gateway | 90 | 3 | 0 | 0 | 5.07 |
| c5-gateway | 100 | 1 | 1 | 1 | 4.97 |
| c6-all | 50 | 3 | 0 | 0 | 7.61 |
| c6-all | 60 | 2 | 1 | 0 | 7.53 |
| c6-all | 70 | 1 | 2 | 0 | 8.91 |
| c6-all | 80 | 2 | 1 | 0 | 7.88 |
| c6-all | 90 | 2 | 0 | 1 | 7.35 |
| c6-all | 100 | 1 | 0 | 2 | 7.04 |

### /health overhead from medians, runs without collapse (post-hoc)

A cell needs at least 2 such runs for the configuration and the baseline.

| Rate req/s | Baseline median ms | Δ c5-gateway ms | Δ c6-all ms |
| --- | --- | --- | --- |
| 50 | 1.98 | +3.38 (n=3) | +5.62 (n=3) |
| 60 | 2.08 | +2.81 (n=3) | +5.45 (n=3) |
| 70 | 1.99 | +2.66 (n=2) | +6.92 (n=3) |
| 80 | 2.01 | +3.27 (n=3) | +5.87 (n=3) |
| 90 | 2.02 | +3.05 (n=3) | +5.33 (n=2) |
| 100 | 1.96 | +3.00 (n=2) | n/a (2 of 3 collapsed) |
| 150 | 1.99 | - | - |
| 200 | 1.90 | - | - |

### CPU per pod on the /health path (millicores, mean of run means)

CPU limits in the manifests: fastapi 1000 m, gateway 500 m, traefik none. A pod at its limit is throttled by the kernel.
Pods that are not on the request path of a configuration show '-'.

| Config | Rate req/s | fastapi m | gateway m | traefik m |
| --- | --- | --- | --- | --- |
| c0-baseline | 50 | 97 | - | - |
| c0-baseline | 60 | 118 | - | - |
| c0-baseline | 70 | 132 | - | - |
| c0-baseline | 80 | 154 | - | - |
| c0-baseline | 90 | 177 | - | - |
| c0-baseline | 100 | 195 | - | - |
| c0-baseline | 150 | 301 | - | - |
| c0-baseline | 200 | 412 | - | - |
| c5-gateway | 50 | 105 | 196 | - |
| c5-gateway | 60 | 116 | 218 | - |
| c5-gateway | 70 | 143 | 272 | - |
| c5-gateway | 80 | 156 | 288 | - |
| c5-gateway | 90 | 177 | 323 | - |
| c5-gateway | 100 | 183 | 384 | - |
| c6-all | 50 | 136 | 242 | 61 |
| c6-all | 60 | 168 | 292 | 70 |
| c6-all | 70 | 204 | 372 | 87 |
| c6-all | 80 | 214 | 413 | 91 |
| c6-all | 90 | 233 | 463 | 102 |
| c6-all | 100 | 245 | 526 | 111 |

### /chat per number of virtual users

| Config | VUs | Throughput req/s | Avg ms | P95 ms | P99 ms | Failed % | Tokens/s | Runs |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| c0-baseline | 1 | 0.289 | 2596.50 (2002.14-3671.07) | 3505.27 | 5045.82 | 0.00 | 17.2 | 3 |
| c0-baseline | 2 | 0.421 | 3847.70 (3153.98-4997.93) | 4495.77 | 5488.55 | 0.00 | 17.2 | 3 |
| c0-baseline | 4 | 0.430 | 8263.84 (7280.92-9877.41) | 8816.39 | 9449.45 | 0.00 | 17.5 | 3 |
| c6-all | 1 | 0.300 | 2348.13 (2130.17-2707.77) | 2960.33 | 5003.16 | 0.00 | 17.9 | 3 |
| c6-all | 2 | 0.446 | 3469.40 (3143.02-3794.64) | 4105.32 | 4622.59 | 0.00 | 18.2 | 3 |
| c6-all | 4 | 0.457 | 7620.04 (7206.75-8021.46) | 8234.50 | 8547.55 | 0.00 | 18.6 | 3 |

