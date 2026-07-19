function all_results = run_high_confidence(num_runs, rounds)
%RUN_HIGH_CONFIDENCE Final higher-confidence protocol comparison.
%
% Usage:
%   all_results = run_high_confidence;       % 30 runs, default rounds
%   all_results = run_high_confidence(50);   % 50 runs, default rounds

if nargin < 1
    num_runs = 30;
end
if nargin < 2
    rounds = [];
end

clc;
close all;

params = default_params();
params.monte_carlo_runs = num_runs;
if ~isempty(rounds)
    params.rounds = rounds;
end

out_dir = create_results_folder(sprintf('final_high_confidence_%druns', num_runs));
fprintf('High-confidence AERT-UC comparison: %d runs, %d rounds.\n', ...
    params.monte_carlo_runs, params.rounds);

all_results = struct();
for pidx = 1:numel(params.protocols)
    protocol_name = params.protocols{pidx};
    fprintf('Running %s...\n', protocol_name);
    run_results = cell(params.monte_carlo_runs, 1);
    
    for run_id = 1:params.monte_carlo_runs
        seed = params.seed + 900000 + 10000 * pidx + run_id;
        run_results{run_id} = run_protocol(protocol_name, params, seed);
    end
    
    all_results.(protocol_name).runs = run_results;
    all_results.(protocol_name).summary = summarize_runs(run_results, params);
end

summary_table = build_final_summary_table(all_results, params);
all_results.output_folder = out_dir;
all_results.summary_table = summary_table;

save(fullfile(out_dir, 'final_high_confidence_results.mat'), 'all_results', 'params');
writetable(summary_table, fullfile(out_dir, 'final_high_confidence_summary.csv'));
plot_results(all_results, params, out_dir);
plot_publication_curves(all_results, params, out_dir);
print_summary(all_results, params);
disp(summary_table);
fprintf('High-confidence results saved in %s\n', fullfile(pwd, out_dir));
end

function summary_table = build_final_summary_table(all_results, params)
summary_table = table();
for i = 1:numel(params.protocols)
    name = params.protocols{i};
    s = all_results.(name).summary;
    summary_table = [summary_table; table( ...
        string(name), s.first_dead_mean, s.half_dead_mean, s.all_dead_mean, ...
        s.final_packets_bs_mean, s.final_alive_mean, s.final_residual_energy_mean, ...
        s.first_dead_std, s.half_dead_std, s.all_dead_std, s.final_packets_bs_std, ...
        s.first_dead_ci95, s.half_dead_ci95, s.all_dead_ci95, s.final_packets_bs_ci95, ...
        'VariableNames', {'Protocol','FND','HND','AND','Packets_BS','Alive_Final','Residual_Energy', ...
        'FND_Std','HND_Std','AND_Std','Packets_BS_Std','FND_CI95','HND_CI95','AND_CI95','Packets_BS_CI95'})]; %#ok<AGROW>
end
end
