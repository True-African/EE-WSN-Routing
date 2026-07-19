# Established Results and Interpretation

## Confirmatory Experiment

The final stored experiment uses 30 Monte Carlo runs and compares LEACH, SEP, EDD-LEACH, and AWARE-UC under the same default scenario.

| Protocol | FND mean +/- CI95 | HND mean +/- CI95 | AND mean +/- CI95 | Packets mean +/- CI95 |
| --- | ---: | ---: | ---: | ---: |
| LEACH | 348.47 +/- 4.28 | 1048.60 +/- 13.78 | 1411.03 +/- 9.79 | 5276.13 +/- 54.34 |
| SEP | 932.57 +/- 19.01 | 1068.90 +/- 6.07 | 1093.20 +/- 5.86 | 5266.70 +/- 29.09 |
| EDD-LEACH | 348.97 +/- 4.22 | 1046.50 +/- 11.82 | 1406.90 +/- 12.71 | 5219.70 +/- 38.70 |
| AWARE-UC | 1129.90 +/- 6.62 | 2371.40 +/- 52.54 | 4384.40 +/- 60.82 | 10137.60 +/- 14.07 |

Interpret SEP carefully: it delays FND through heterogeneous election probabilities, but does not improve total lifetime or packet delivery under this experiment's assumptions.

## Sink Sweep

The stored sink sweep contains 168 scenario comparisons. AWARE-UC delivered more packets than LEACH and EDD-LEACH in all stored scenarios. Mean AWARE-UC values were FND 640.27, HND 1711.78, AND 4137.75, packets 12655.58, and residual energy 0.33487.

## Shape Sweep

AWARE-UC led packet delivery across square, circular, triangular, and mixed deployments. Gains over LEACH were approximately 84% to 91% in 100 m by 100 m fields and approximately 161% to 197% in 300 m by 300 m fields.

## Dynamic BS

The fixed circular BS path was approximately neutral to slightly worse for AWARE-UC than the static centered BS: packets -0.7%, HND -2.7%, and AND -3.0%. Treat this as evidence that mobility must be energy-aware and optimized, not as evidence against all mobile sinks.

## Claim Boundaries

These are simulation findings, not hardware validation. Avoid universal claims. Future evidence should add heterogeneous traffic, packet loss, delay, network simulators or testbeds, and comparisons with implementable recent protocols under matched assumptions.
