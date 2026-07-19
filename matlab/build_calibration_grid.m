function candidates = build_calibration_grid()
%BUILD_CALIBRATION_GRID Candidate AERT-UC settings biased toward throughput.

profiles = {
    'balanced',      [0.38 0.18 0.16 0.14 0.14], 2.5, 0.05, 0.08, 0.35, 0.70
    'throughput_1',  [0.30 0.25 0.18 0.10 0.17], 1.8, 0.07, 0.05, 0.22, 0.45
    'throughput_2',  [0.28 0.28 0.20 0.08 0.16], 1.5, 0.08, 0.03, 0.18, 0.35
    'lifetime_1',    [0.44 0.14 0.14 0.14 0.14], 3.0, 0.05, 0.10, 0.40, 0.85
    'dense_ch',      [0.32 0.22 0.18 0.10 0.18], 1.8, 0.09, 0.04, 0.20, 0.40
    'sink_aware',    [0.30 0.32 0.14 0.08 0.16], 1.7, 0.07, 0.04, 0.16, 0.35
};

candidates = struct([]);
for i = 1:size(profiles, 1)
    weights = profiles{i, 2};
    candidates(i).name = profiles{i, 1}; %#ok<AGROW>
    candidates(i).weights.energy = weights(1); %#ok<AGROW>
    candidates(i).weights.sink_distance = weights(2); %#ok<AGROW>
    candidates(i).weights.density = weights(3); %#ok<AGROW>
    candidates(i).weights.fairness = weights(4); %#ok<AGROW>
    candidates(i).weights.availability = weights(5); %#ok<AGROW>
    candidates(i).threshold_risk_multiplier = profiles{i, 3}; %#ok<AGROW>
    candidates(i).target_ch_fraction = profiles{i, 4}; %#ok<AGROW>
    candidates(i).relay_saving_margin = profiles{i, 5}; %#ok<AGROW>
    candidates(i).member_forward_weight = profiles{i, 6}; %#ok<AGROW>
    candidates(i).load_balance_weight = profiles{i, 7}; %#ok<AGROW>
end
end
