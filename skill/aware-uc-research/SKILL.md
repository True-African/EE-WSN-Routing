---
name: aware-uc-research
description: Run, calibrate, analyze, validate, and document AWARE-UC wireless sensor network experiments in MATLAB. Use for AWARE-UC protocol work involving LEACH, SEP, or EDD-LEACH baselines; Monte Carlo runs; field-shape or sink-placement sweeps; dynamic base-station experiments; confidence intervals; publication plots; mathematical modeling; pseudocode; or thesis manuscript updates.
---

# AWARE-UC Research

Use this skill to maintain a reproducible path from MATLAB parameters to paper-ready evidence for AWARE-UC: Availability and Weighted-energy Adaptive Routing with Uneven Clustering.

## Orient

1. Locate the repository root containing `matlab/`, `results/`, and `manuscript/`.
2. Read [references/workflow.md](references/workflow.md) for experiment order and artifact conventions.
3. Read [references/model.md](references/model.md) before changing scoring weights, threshold terms, competition radius, assignment cost, or relay logic.
4. Read [references/results.md](references/results.md) when interpreting established evidence or updating the manuscript.
5. Preserve the implementation alias: `protocol_aert_uc.m` is the core implementation; `protocol_aware_uc.m` is the manuscript-facing wrapper.

## Run Experiments

Open MATLAB in `matlab/`. Run the narrowest experiment that answers the research question:

```matlab
main_aert_uc
run_aert_calibration
run_scenario_sweep('core')
run_sink_sweep
run_dynamic_bs_case
run_high_confidence(30)
```

Keep each run in a timestamped result folder. Never overwrite confirmatory evidence with exploratory output. Use identical seeds and radio parameters when comparing protocols.

## Change the Protocol

Treat a parameter adjustment as calibration unless it changes the decision structure. Treat a new score term, threshold function, clustering rule, or routing rule as an algorithm revision.

After any algorithm revision:

1. Update `protocol_aert_uc.m` and preserve the `protocol_aware_uc.m` wrapper.
2. Update `default_params.m` and the model reference.
3. Run a smoke test, calibration, core sweep, sink sweep, and confirmatory run in that order.
4. Report mean, standard deviation, and 95% confidence interval for final Monte Carlo results.
5. Keep exploratory dynamic-BS evidence separate from confirmatory static-center evidence.

## Analyze Results

Use FND, HND, AND, packets delivered to the BS, final alive nodes, and residual energy. Compare every protocol under the same scenario and seeds. Explain tradeoffs: delaying FND alone does not establish better total lifetime or throughput.

Do not claim superiority beyond tested scenarios. State Monte Carlo count, field geometry, node count, sink placement, radio model, and initial-energy assumptions near every major comparison.

## Update the Manuscript

Use `tools/generate_manuscript.py` from the repository root to regenerate the draft. Keep formulas, symbol definitions, pseudocode, captions, and MATLAB code synchronized. Discuss every figure in the body before or immediately after it appears.

Run the bundled validator after regeneration:

```powershell
python skill/aware-uc-research/scripts/validate_manuscript.py manuscript/AWARE-UC-research-draft.docx
```

Use `manuscript/AWARE_UC_references_2020_2026.bib` for reference-manager import. Do not fabricate citation metadata; verify DOI records before final submission.

## Guardrails

- Do not publish tokens, passwords, signed thesis files, private correspondence, or unrelated research artifacts.
- Do not silently mix preliminary, calibration, exploratory, and confirmatory results.
- Do not rename the core implementation without preserving backward compatibility.
- Do not describe the fixed circular BS path as an optimized mobile-sink algorithm.
- Validate MATLAB outputs and the generated document before claiming completion.
