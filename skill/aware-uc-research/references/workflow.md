# Experiment Workflow

## Order of Work

1. Run `main_aert_uc` as a smoke and integration test.
2. Run `run_aert_calibration` to compare parameter profiles.
3. Set the selected profile in `default_params.m`.
4. Run `run_scenario_sweep('core')` for field-size and shape evidence.
5. Run `run_sink_sweep` for sink-placement evidence.
6. Run `run_dynamic_bs_case` as exploratory mobility evidence.
7. Run `run_high_confidence(30)` or more for confirmatory evidence.
8. Run publication analysis and regenerate the manuscript.

## Evidence Classes

- Smoke tests: confirm execution and metric plausibility; never use as final evidence.
- Calibration: select parameters; do not reuse the same results as unbiased confirmation.
- Scenario sweeps: test robustness across geometry, density, and sink placement.
- Dynamic BS: exploratory comparison unless the movement rule is independently optimized and confirmed.
- High confidence: final Monte Carlo comparison with means, standard deviations, and 95% confidence intervals.

## Reproducibility Rules

- Compare protocols with shared deployment seeds.
- Keep radio parameters, packet size, initial energy, rounds, and topology identical within a scenario.
- Save outputs in timestamped folders.
- Preserve raw `.mat` histories for confirmatory curves and CSV summaries for inspection.
- Record code revision, MATLAB version, run count, and random seeds for final publication.

## Scenario Vocabulary

- `square`: uniform rectangular field.
- `circle`: uniform deployment inside a centered circle.
- `triangle`: uniform deployment inside a triangular region.
- `mixed`: 45% rectangular, 30% circular, and 25% triangular deployment components.
- `center`, `edge-*`, `corner`, `outside-top`: static sink placements.
- `dynamic circle`: fixed circular BS trajectory used only as exploratory evidence.
