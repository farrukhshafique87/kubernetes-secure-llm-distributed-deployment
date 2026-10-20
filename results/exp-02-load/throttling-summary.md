### CPU throttling of `gateway` (share of CFS periods)

Mean: average over runs of the per-run mean. Max: highest 1-minute
value in any run of that level.

| Config | Rate req/s | Runs | Mean % | Max % |
| --- | --- | --- | --- | --- |
| c5-gateway | 50 | 3 | 3.0 | 15.2 |
| c5-gateway | 60 | 3 | 0.1 | 0.4 |
| c5-gateway | 70 | 3 | 12.0 | 61.0 |
| c5-gateway | 80 | 3 | 3.0 | 12.0 |
| c5-gateway | 90 | 3 | 11.8 | 33.9 |
| c5-gateway | 100 | 3 | 37.7 | 100.0 |
| c6-all | 50 | 3 | 0.2 | 0.9 |
| c6-all | 60 | 3 | 1.9 | 7.4 |
| c6-all | 70 | 3 | 6.1 | 21.5 |
| c6-all | 80 | 3 | 4.4 | 25.2 |
| c6-all | 90 | 3 | 29.8 | 100.0 |
| c6-all | 100 | 3 | 48.5 | 100.0 |

### CPU throttling of `fastapi` (share of CFS periods)

Mean: average over runs of the per-run mean. Max: highest 1-minute
value in any run of that level.

| Config | Rate req/s | Runs | Mean % | Max % |
| --- | --- | --- | --- | --- |
| c0-baseline | 50 | 3 | 0.0 | 0.0 |
| c0-baseline | 60 | 3 | 0.0 | 0.0 |
| c0-baseline | 70 | 3 | 0.0 | 0.0 |
| c0-baseline | 80 | 3 | 0.0 | 0.0 |
| c0-baseline | 90 | 3 | 0.0 | 0.0 |
| c0-baseline | 100 | 3 | 0.0 | 0.0 |
| c0-baseline | 150 | 3 | 0.0 | 0.6 |
| c0-baseline | 200 | 3 | 0.1 | 0.5 |
| c5-gateway | 50 | 3 | 0.0 | 0.0 |
| c5-gateway | 60 | 3 | 0.0 | 0.0 |
| c5-gateway | 70 | 3 | 0.0 | 0.0 |
| c5-gateway | 80 | 3 | 0.0 | 0.0 |
| c5-gateway | 90 | 3 | 0.0 | 0.0 |
| c5-gateway | 100 | 3 | 0.0 | 0.0 |
| c6-all | 50 | 3 | 0.0 | 0.0 |
| c6-all | 60 | 3 | 0.0 | 0.0 |
| c6-all | 70 | 3 | 0.0 | 0.0 |
| c6-all | 80 | 3 | 0.0 | 0.0 |
| c6-all | 90 | 3 | 0.0 | 0.0 |
| c6-all | 100 | 3 | 0.0 | 0.0 |

### CPU throttling of `linkerd-proxy` (share of CFS periods)

Mean: average over runs of the per-run mean. Max: highest 1-minute
value in any run of that level.

| Config | Rate req/s | Runs | Mean % | Max % |
| --- | --- | --- | --- | --- |
| c6-all | 50 | 3 | 0.0 | 0.0 |
| c6-all | 60 | 3 | 0.0 | 0.1 |
| c6-all | 70 | 3 | 0.0 | 0.0 |
| c6-all | 80 | 3 | 0.0 | 0.0 |
| c6-all | 90 | 3 | 0.0 | 0.1 |
| c6-all | 100 | 3 | 0.0 | 0.0 |

