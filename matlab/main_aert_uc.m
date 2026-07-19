function all_results = main_aert_uc()
%MAIN_AERT_UC Run baseline and proposed WSN routing simulations.

clc;
close all;

params = default_params();
out_dir = create_results_folder('main');
fprintf('AERT-UC simulation started with %d Monte Carlo runs.\n', params.monte_carlo_runs);

all_results = struct();
for pidx = 1:numel(params.protocols)
    protocol_name = params.protocols{pidx};
    fprintf('Running %s...\n', protocol_name);
    run_results = cell(params.monte_carlo_runs, 1);
    
    for run_id = 1:params.monte_carlo_runs
        seed = params.seed + run_id;
        run_results{run_id} = run_protocol(protocol_name, params, seed);
    end
    
    all_results.(protocol_name).runs = run_results;
    all_results.(protocol_name).summary = summarize_runs(run_results, params);
end

all_results.output_folder = out_dir;
save(fullfile(out_dir, 'aert_uc_results.mat'), 'all_results', 'params');
plot_results(all_results, params, out_dir);
print_summary(all_results, params);
fprintf('Done. Results saved in %s\n', fullfile(pwd, out_dir));
end
