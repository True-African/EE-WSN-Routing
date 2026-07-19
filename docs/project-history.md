# Project History

## Origin

The project began as a reassessment of a 2020 master's thesis on data availability and energy-aware routing in wireless sensor networks. The old MATLAB scripts and thesis plots were reviewed to identify useful assumptions and limitations. A separate `AERT_UC_Project` workspace was then created so the new protocol would not depend on another researcher's simulator.

## Simulator Reconstruction

A shared MATLAB simulation platform was developed around `default_params.m`, `init_network.m`, radio transmission and reception functions, protocol dispatch, common metrics, and timestamped result folders. LEACH and the thesis-inspired EDD-LEACH were reimplemented under the same radio model. The proposed protocol began under the working name AERT-UC.

## Protocol Development

The protocol evolved to combine adaptive energy thresholding, weighted CH scoring, uneven CH competition, energy-cost member assignment, and conditional relay forwarding. Calibration compared balanced, throughput, lifetime, dense-CH, and sink-aware profiles. The `dense_ch` profile became the default after it produced the strongest packet-delivery/lifetime balance.

For clearer communication, the manuscript name became AWARE-UC: Availability and Weighted-energy Adaptive Routing with Uneven Clustering. `protocol_aert_uc.m` remains the core implementation for reproducibility, while `protocol_aware_uc.m` provides naming consistency.

## Evidence Development

The research progressed through distinct stages:

1. Smoke tests established that all implementations generated valid histories.
2. Calibration selected weights and thresholds.
3. Core sweeps tested field size and square, circular, triangular, and mixed deployments.
4. Sink sweeps tested center, edges, corner, and outside placements.
5. A fixed circular dynamic-BS case was treated as exploratory evidence.
6. A 30-run Monte Carlo experiment provided confirmatory means, standard deviations, and 95% confidence intervals.
7. SEP was added as an additional baseline.

## Research Writing

A standalone manuscript was generated rather than modifying the signed original thesis. It includes an expanded background, updated references, a recent-protocol comparison, symbol table, first-order radio model, mathematical definition, complexity analysis, pseudocode, an AWARE-UC flowchart, test-versus-confirmatory result framing, and coherent discussion of each figure.

The bibliography is supplied in BibTeX for import into Mendeley. Dynamic citation fields must be inserted through Mendeley Cite in Word; account credentials are never part of this repository.

## Current Boundary

The repository preserves simulation evidence. It does not yet establish hardware-testbed performance, packet-loss behavior, latency, security properties, or superiority over every recent optimization protocol. Those are appropriate next validation stages.
