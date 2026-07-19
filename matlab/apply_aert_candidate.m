function params = apply_aert_candidate(params, candidate)
%APPLY_AERT_CANDIDATE Apply one calibration profile to params.

params.aert.weights = candidate.weights;
params.threshold.risk_multiplier = candidate.threshold_risk_multiplier;
params.aert.target_ch_fraction = candidate.target_ch_fraction;
params.aert.relay_saving_margin = candidate.relay_saving_margin;
params.aert.member_forward_weight = candidate.member_forward_weight;
params.aert.load_balance_weight = candidate.load_balance_weight;
end
