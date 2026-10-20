### CPU throttling of `gateway` (share of CFS periods)

Mean: average over runs of the per-run mean. Max: highest 1-minute
value in any run of that level.

| Config | Rate req/s | Runs | Mean % | Max % |
| --- | --- | --- | --- | --- |
| c5-gateway | 50 | 3 | 0.0 | 0.3 |
| c5-gateway | 60 | 3 | 0.1 | 0.2 |
| c5-gateway | 70 | 3 | 0.3 | 1.4 |
| c5-gateway | 80 | 3 | 1.6 | 6.4 |
| c5-gateway | 90 | 3 | 5.3 | 18.6 |
| c5-gateway | 100 | 3 | 7.4 | 18.1 |
| c5-gateway-cpu1000 | 50 | 3 | 0.0 | 0.0 |
| c5-gateway-cpu1000 | 60 | 3 | 0.0 | 0.2 |
| c5-gateway-cpu1000 | 70 | 3 | 0.1 | 0.9 |
| c5-gateway-cpu1000 | 80 | 3 | 0.0 | 0.2 |
| c5-gateway-cpu1000 | 90 | 3 | 0.0 | 0.0 |
| c5-gateway-cpu1000 | 100 | 3 | 0.0 | 0.0 |
| c5-gateway-cpu1000 | 120 | 3 | 0.1 | 0.6 |
| c5-gateway-cpu1000 | 150 | 3 | 0.4 | 1.3 |

### CPU throttling of `fastapi` (share of CFS periods)

Mean: average over runs of the per-run mean. Max: highest 1-minute
value in any run of that level.

| Config | Rate req/s | Runs | Mean % | Max % |
| --- | --- | --- | --- | --- |
| c0-baseline | 50 | 3 | 0.0 | 0.0 |
| c0-baseline | 60 | 3 | 0.0 | 0.0 |
| c0-baseline | 70 | 3 | 0.1 | 0.7 |
| c0-baseline | 80 | 3 | 0.0 | 0.0 |
| c0-baseline | 90 | 3 | 0.0 | 0.0 |
| c0-baseline | 100 | 3 | 0.0 | 0.0 |
| c0-baseline | 120 | 3 | 0.0 | 0.0 |
| c0-baseline | 150 | 3 | 0.0 | 0.0 |
| c5-gateway | 50 | 3 | 0.0 | 0.0 |
| c5-gateway | 60 | 3 | 0.0 | 0.0 |
| c5-gateway | 70 | 3 | 0.0 | 0.0 |
| c5-gateway | 80 | 3 | 0.0 | 0.0 |
| c5-gateway | 90 | 3 | 0.0 | 0.0 |
| c5-gateway | 100 | 3 | 0.0 | 0.0 |
| c5-gateway-cpu1000 | 50 | 3 | 0.0 | 0.0 |
| c5-gateway-cpu1000 | 60 | 3 | 0.0 | 0.0 |
| c5-gateway-cpu1000 | 70 | 3 | 0.0 | 0.0 |
| c5-gateway-cpu1000 | 80 | 3 | 0.0 | 0.0 |
| c5-gateway-cpu1000 | 90 | 3 | 0.0 | 0.0 |
| c5-gateway-cpu1000 | 100 | 3 | 0.0 | 0.0 |
| c5-gateway-cpu1000 | 120 | 3 | 0.0 | 0.0 |
| c5-gateway-cpu1000 | 150 | 3 | 0.0 | 0.0 |

