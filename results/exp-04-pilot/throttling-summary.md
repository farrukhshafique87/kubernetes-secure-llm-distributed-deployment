### CPU throttling of `gateway` (share of CFS periods)

Mean: average over runs of the per-run mean. Max: highest 1-minute
value in any run of that level.

| Config | Rate req/s | Runs | Mean % | Max % |
| --- | --- | --- | --- | --- |
| c5-gateway | 70 | 1 | 1.1 | 1.8 |
| c5-gateway | 100 | 1 | 8.7 | 13.8 |
| c5-gateway-cpu1000 | 70 | 1 | 0.0 | 0.0 |
| c5-gateway-cpu1000 | 100 | 1 | 0.0 | 0.0 |

### CPU throttling of `fastapi` (share of CFS periods)

Mean: average over runs of the per-run mean. Max: highest 1-minute
value in any run of that level.

| Config | Rate req/s | Runs | Mean % | Max % |
| --- | --- | --- | --- | --- |
| c5-gateway | 70 | 1 | 0.0 | 0.0 |
| c5-gateway | 100 | 1 | 0.0 | 0.0 |
| c5-gateway-cpu1000 | 70 | 1 | 0.0 | 0.0 |
| c5-gateway-cpu1000 | 100 | 1 | 0.0 | 0.0 |

