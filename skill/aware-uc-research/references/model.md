# AWARE-UC Model Reference

## Name and Implementation

AWARE-UC means Availability and Weighted-energy Adaptive Routing with Uneven Clustering. The core MATLAB function remains `protocol_aert_uc.m` for traceability; `protocol_aware_uc.m` is the public wrapper.

## Radio Model

For a `k`-bit packet and distance `d`:

`E_TX(k,d) = k E_elec + k E_fs d^2` when `d <= d0`.

`E_TX(k,d) = k E_elec + k E_mp d^4` when `d > d0`.

`d0 = sqrt(E_fs / E_mp)`, `E_RX(k) = k E_elec`, and `E_RXA(k) = k(E_elec + E_DA)`.

## Adaptive Availability Threshold

`E_th(r) = max(E_floor, lambda E_pkt [1 + alpha P_E(r) + beta P_R(r)])`, bounded above by `0.18 E0`.

Current calibration: `lambda=1.8`, `alpha=0.6`, `beta=0.4`, and `E_floor=10^-4 E0`.

A node is available only when `E_i(r) > E_th(r)`.

## Cluster-Head Score

`Score_i = w_E R_i + w_D B_i + w_L L_i + w_F F_i + w_A A_i`.

Current weights: `w_E=0.32`, `w_D=0.22`, `w_L=0.18`, `w_F=0.10`, and `w_A=0.18`.

The terms represent residual energy, BS-distance advantage, local density, CH-role fairness, and availability margin.

## Uneven Clustering

`R_i^comp = R_min + (R_max - R_min)(d_i,BS / d_max,BS)`.

Current values: `R_min=8`, `R_max=28`, and target CH fraction `p_CH=0.09`.

## Assignment and Relay

`Cost(i,c) = E_TX(k,d_ic) + gamma E_TX(k,d_c,BS) + mu Load_c E_RXA(k)`.

Current values: `gamma=0.20` and `mu=0.40`.

Use a relay only when all participating nodes remain above the threshold and the relay path costs less than `(1-delta)` times direct transmission. Current `delta=0.04`.

## Complexity

Availability and score calculation are `O(N)`. Pairwise density and competition checks are `O(N^2)`. Member assignment is `O(NC)` and CH relay evaluation is `O(C^2)`. The direct implementation is therefore `O(N^2)` per round, with `C << N` in normal operation.
