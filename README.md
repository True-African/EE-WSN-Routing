# EE WSN Power Threshold Routing

A reproducible MATLAB research package for **AWARE-UC: Availability and Weighted-energy Adaptive Routing with Uneven Clustering**, an energy-aware clustering and routing protocol for wireless sensor networks.

The repository contains the protocol implementation, LEACH/SEP/EDD-LEACH baselines, calibration and scenario runners, confirmatory results, publication figures, a manuscript draft, bibliography, and a reusable Codex skill.

## Repository Layout

```text
matlab/       MATLAB simulator, protocols, runners, and analysis
results/      Selected confirmatory and scenario-sweep evidence
manuscript/   Research draft, figures, and reference-manager files
tools/        Portable manuscript and flowchart generators
skill/        Reusable aware-uc-research Codex skill
docs/         Research history and reproducibility notes
```

## Requirements

- MATLAB with table and plotting support
- Python 3 with `python-docx` and Pillow for manuscript generation

## MATLAB Quick Start

Open MATLAB in `matlab/` and run:

```matlab
main_aert_uc
run_aert_calibration
run_scenario_sweep('core')
run_sink_sweep
run_dynamic_bs_case
run_high_confidence(30)
```

Each new run is written to its own timestamped folder under `matlab/results/`.

## Protocols

- `LEACH`: randomized homogeneous baseline.
- `SEP`: heterogeneous-energy election baseline.
- `EDD_LEACH`: threshold-aware baseline derived from the earlier thesis concept.
- `AWARE_UC`: proposed protocol exposed through `protocol_aware_uc.m`.

The core proposed implementation remains `protocol_aert_uc.m` for traceability with earlier experiments.

## Main Evidence

The stored 30-run confirmatory experiment reports AWARE-UC mean FND `1129.90`, HND `2371.40`, AND `4384.40`, and `10137.60` packets delivered to the BS. The stored sink sweep covers 168 comparisons, and the core sweep covers square, circular, triangular, and mixed deployments.

See [results.md](skill/aware-uc-research/references/results.md) for confidence intervals and interpretation limits.

## Manuscript

The current draft is [AWARE-UC-research-draft.docx](manuscript/AWARE-UC-research-draft.docx). Regenerate it from repository-relative assets with:

```powershell
python tools/generate_manuscript.py
python skill/aware-uc-research/scripts/validate_manuscript.py manuscript/AWARE-UC-research-draft.docx
```

Import `manuscript/AWARE_UC_references_2020_2026.bib` into a dedicated Mendeley collection to create dynamic Word citations. Verify DOI metadata before submission.

## Codex Skill

The reusable skill is located at `skill/aware-uc-research`. Install or copy that folder into your Codex skills directory, then invoke `$aware-uc-research` for simulation, analysis, or manuscript work.

## Privacy and Scope

The signed original thesis, credentials, private correspondence, and redundant exploratory binaries are intentionally excluded. Publication of this repository does not grant a license beyond rights provided by applicable law; add an explicit license before inviting reuse.
