function calibration = run_aert_calibration()
%RUN_AERT_CALIBRATION Tune AERT-UC profiles for packet delivery.

params = default_params();
candidates = build_calibration_grid();
run_count = params.calibration_runs;
out_dir = create_results_folder('calibration');

fprintf('AERT-UC calibration: %d candidates, %d runs each.\n', numel(candidates), run_count);
rows = table();

for c = 1:numel(candidates)
    trial_params = apply_aert_candidate(params, candidates(c));
    run_results = cell(run_count, 1);
    fprintf('Candidate %s...\n', candidates(c).name);
    
    for run_id = 1:run_count
        seed = params.seed + 1000 * c + run_id;
        run_results{run_id} = protocol_aert_uc(trial_params, seed);
    end
    
    summary = summarize_runs(run_results, trial_params);
    score = calibration_score(summary);
    rows = [rows; table( ...
        string(candidates(c).name), ...
        summary.first_dead_mean, summary.half_dead_mean, summary.all_dead_mean, ...
        summary.final_packets_bs_mean, summary.final_alive_mean, ...
        summary.final_residual_energy_mean, score, ...
        'VariableNames', {'Candidate','FND','HND','AND','Packets_BS','Alive_Final','Residual_Energy','Score'})]; %#ok<AGROW>
end

rows = sortrows(rows, 'Score', 'descend');
calibration.table = rows;
calibration.best = rows(1, :);
calibration.candidates = candidates;
calibration.output_folder = out_dir;

writetable(rows, fullfile(out_dir, 'aert_calibration.csv'));
save(fullfile(out_dir, 'aert_calibration.mat'), 'calibration', 'params');
disp(rows);
fprintf('Calibration results saved in %s\n', fullfile(pwd, out_dir));
end

function score = calibration_score(summary)
% Packet-first score with lifetime guardrails.
score = summary.final_packets_bs_mean ...
    + 0.45 * summary.first_dead_mean ...
    + 0.12 * summary.half_dead_mean ...
    + 0.04 * summary.all_dead_mean;
end
