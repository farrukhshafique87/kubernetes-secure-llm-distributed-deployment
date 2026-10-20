### results/exp-01-baseline

| Config | Runs | Avg ms | P95 ms | P99 ms | Max ms | Req/s | Failed % | Tokens/s |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| c0-baseline-health | 3 | 1.97 (1.93-2.03) | 2.81 (2.68-2.98) | - | 25.2 (20.1-33.2) | 50.01 (50.00-50.01) | 0.00 | - |
| c0-baseline | 3 | 2001.20 (1996.42-2009.65) | 2151.45 (2124.47-2186.43) | - | 2333.6 (2230.6-2452.1) | 0.33 (0.33-0.33) | 0.00 | 19.99 (19.93-20.03) |

| Config | Pod | CPU m (mean of run means) | Memory Mi |
| --- | --- | --- | --- |
| c0-baseline-health | fastapi | 87 (85-90) | 47 (46-49) |
| c0-baseline-health | ollama | 1 | 647 (646-647) |
| c0-baseline | fastapi | 9 (8-9) | 45 (45-45) |
| c0-baseline | ollama | 1649 (1646-1651) | 647 (647-647) |

