### /health latency per request rate

| Config | Target req/s | Achieved req/s | Avg ms | P95 ms | P99 ms | Failed % | Dropped | Runs | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| c0-baseline | 50 | 50.0 | 2.44 (2.21-2.81) | 3.72 | 5.22 | 0.00 | 0 | 3 | ok |
| c0-baseline | 60 | 60.0 | 2.82 (2.04-3.45) | 3.92 | 5.40 | 0.00 | 0 | 3 | ok |
| c0-baseline | 70 | 70.0 | 4.20 (2.07-7.64) | 4.08 | 64.71 | 0.00 | 10 | 3 | saturated |
| c0-baseline | 80 | 80.0 | 2.28 (1.96-2.74) | 3.47 | 4.70 | 0.00 | 0 | 3 | ok |
| c0-baseline | 90 | 90.0 | 2.30 (1.96-2.78) | 3.48 | 4.92 | 0.00 | 0 | 3 | ok |
| c0-baseline | 100 | 100.0 | 2.37 (2.00-2.97) | 3.61 | 5.19 | 0.00 | 0 | 3 | ok |
| c0-baseline | 120 | 120.0 | 2.26 (1.94-2.76) | 3.47 | 4.99 | 0.00 | 0 | 3 | ok |
| c0-baseline | 150 | 150.0 | 2.27 (1.93-2.68) | 3.53 | 5.77 | 0.00 | 0 | 3 | ok |
| c5-gateway | 50 | 50.0 | 4.69 (4.57-4.88) | 6.79 | 9.04 | 0.00 | 0 | 3 | ok |
| c5-gateway | 60 | 60.0 | 4.64 (4.35-4.97) | 6.60 | 9.61 | 0.00 | 0 | 3 | ok |
| c5-gateway | 70 | 70.0 | 4.76 (4.63-5.02) | 6.89 | 10.19 | 0.00 | 0 | 3 | ok |
| c5-gateway | 80 | 80.0 | 5.81 (4.55-8.20) | 8.87 | 41.72 | 0.00 | 0 | 3 | ok |
| c5-gateway | 90 | 90.0 | 10.33 (4.46-21.41) | 37.20 | 131.60 | 0.00 | 0 | 3 | ok |
| c5-gateway | 100 | 99.9 | 22.98 (12.95-37.60) | 67.05 | 541.51 | 0.00 | 38 | 3 | saturated |
| c5-gateway-cpu1000 | 50 | 50.0 | 5.12 (4.42-6.41) | 7.72 | 10.02 | 0.00 | 0 | 3 | ok |
| c5-gateway-cpu1000 | 60 | 60.0 | 6.84 (4.46-9.50) | 8.83 | 22.78 | 0.00 | 0 | 3 | ok |
| c5-gateway-cpu1000 | 70 | 70.0 | 10.63 (4.42-20.97) | 8.96 | 215.58 | 0.00 | 16 | 3 | saturated |
| c5-gateway-cpu1000 | 80 | 80.0 | 6.37 (4.64-8.05) | 8.31 | 25.13 | 0.00 | 0 | 3 | ok |
| c5-gateway-cpu1000 | 90 | 90.0 | 5.16 (4.53-6.18) | 7.87 | 12.65 | 0.00 | 0 | 3 | ok |
| c5-gateway-cpu1000 | 100 | 100.0 | 5.26 (4.42-6.57) | 7.87 | 13.00 | 0.00 | 0 | 3 | ok |
| c5-gateway-cpu1000 | 120 | 120.0 | 7.15 (4.59-10.54) | 11.76 | 65.10 | 0.00 | 0 | 3 | ok |
| c5-gateway-cpu1000 | 150 | 149.2 | 48.55 (7.83-115.12) | 253.40 | 1000.87 | 0.00 | 280 | 3 | saturated |

### /health overhead against the baseline at each rate

| Rate req/s | Baseline avg ms | Δ c5-gateway ms | Δ c5-gateway-cpu1000 ms |
| --- | --- | --- | --- |
| 50 | 2.44 | +2.25 (distinct, higher) | +2.68 (distinct, higher) |
| 60 | 2.82 | +1.82 (distinct, higher) | +4.02 (distinct, higher) |
| 70 | 4.20 | n/a (saturated) | n/a (saturated) |
| 80 | 2.28 | +3.53 (distinct, higher) | +4.09 (distinct, higher) |
| 90 | 2.30 | +8.03 (distinct, higher) | +2.86 (distinct, higher) |
| 100 | 2.37 | n/a (saturated) | +2.89 (distinct, higher) |
| 120 | 2.26 | - | +4.88 (distinct, higher) |
| 150 | 2.27 | - | n/a (saturated) |

### /health runs per level (post-hoc, methodology 9.6)

| Config | Rate req/s | Stable | Transient | Collapse | Median ms (runs without collapse) |
| --- | --- | --- | --- | --- | --- |
| c0-baseline | 50 | 3 | 0 | 0 | 2.08 |
| c0-baseline | 60 | 3 | 0 | 0 | 2.18 |
| c0-baseline | 70 | 2 | 1 | 0 | 2.45 |
| c0-baseline | 80 | 3 | 0 | 0 | 1.94 |
| c0-baseline | 90 | 3 | 0 | 0 | 1.93 |
| c0-baseline | 100 | 3 | 0 | 0 | 1.93 |
| c0-baseline | 120 | 3 | 0 | 0 | 1.86 |
| c0-baseline | 150 | 3 | 0 | 0 | 1.86 |
| c5-gateway | 50 | 3 | 0 | 0 | 4.28 |
| c5-gateway | 60 | 3 | 0 | 0 | 4.28 |
| c5-gateway | 70 | 3 | 0 | 0 | 4.30 |
| c5-gateway | 80 | 3 | 0 | 0 | 4.28 |
| c5-gateway | 90 | 3 | 0 | 0 | 4.32 |
| c5-gateway | 100 | 2 | 1 | 0 | 4.50 |
| c5-gateway-cpu1000 | 50 | 3 | 0 | 0 | 4.13 |
| c5-gateway-cpu1000 | 60 | 3 | 0 | 0 | 5.35 |
| c5-gateway-cpu1000 | 70 | 2 | 1 | 0 | 5.01 |
| c5-gateway-cpu1000 | 80 | 3 | 0 | 0 | 4.22 |
| c5-gateway-cpu1000 | 90 | 3 | 0 | 0 | 4.18 |
| c5-gateway-cpu1000 | 100 | 3 | 0 | 0 | 4.27 |
| c5-gateway-cpu1000 | 120 | 3 | 0 | 0 | 5.36 |
| c5-gateway-cpu1000 | 150 | 2 | 0 | 1 | 5.08 |

### /health overhead from medians, runs without collapse (post-hoc)

A cell needs at least 2 such runs for the configuration and the baseline.

| Rate req/s | Baseline median ms | Δ c5-gateway ms | Δ c5-gateway-cpu1000 ms |
| --- | --- | --- | --- |
| 50 | 2.08 | +2.20 (n=3) | +2.05 (n=3) |
| 60 | 2.18 | +2.09 (n=3) | +3.16 (n=3) |
| 70 | 2.45 | +1.85 (n=3) | +2.56 (n=3) |
| 80 | 1.94 | +2.34 (n=3) | +2.28 (n=3) |
| 90 | 1.93 | +2.39 (n=3) | +2.26 (n=3) |
| 100 | 1.93 | +2.58 (n=3) | +2.35 (n=3) |
| 120 | 1.86 | - | +3.50 (n=3) |
| 150 | 1.86 | - | +3.21 (n=2) |

### CPU per pod on the /health path (millicores, mean of run means)

CPU limits in the manifests: fastapi 1000 m, gateway 500 m, traefik none. A pod at its limit is throttled by the kernel.
Pods that are not on the request path of a configuration show '-'.

| Config | Rate req/s | fastapi m | gateway m | traefik m |
| --- | --- | --- | --- | --- |
| c0-baseline | 50 | 107 | - | - |
| c0-baseline | 60 | 131 | - | - |
| c0-baseline | 70 | 163 | - | - |
| c0-baseline | 80 | 161 | - | - |
| c0-baseline | 90 | 176 | - | - |
| c0-baseline | 100 | 200 | - | - |
| c0-baseline | 120 | 238 | - | - |
| c0-baseline | 150 | 280 | - | - |
| c5-gateway | 50 | 82 | 150 | - |
| c5-gateway | 60 | 98 | 176 | - |
| c5-gateway | 70 | 116 | 228 | - |
| c5-gateway | 80 | 132 | 237 | - |
| c5-gateway | 90 | 143 | 271 | - |
| c5-gateway | 100 | 170 | 330 | - |
| c5-gateway-cpu1000 | 50 | 88 | 161 | - |
| c5-gateway-cpu1000 | 60 | 118 | 213 | - |
| c5-gateway-cpu1000 | 70 | 135 | 256 | - |
| c5-gateway-cpu1000 | 80 | 146 | 276 | - |
| c5-gateway-cpu1000 | 90 | 153 | 297 | - |
| c5-gateway-cpu1000 | 100 | 179 | 339 | - |
| c5-gateway-cpu1000 | 120 | 211 | 406 | - |
| c5-gateway-cpu1000 | 150 | 271 | 562 | - |

