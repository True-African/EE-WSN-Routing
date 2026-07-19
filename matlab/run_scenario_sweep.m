function sweep = run_scenario_sweep(mode)
%RUN_SCENARIO_SWEEP Compare protocols across field shapes and sink placement.

if nargin < 1
    mode = 'core';
end

base_params = default_params();
scenarios = build_scenarios(mode);
protocols = base_params.protocols;
run_count = max(3, min(base_params.calibration_runs, base_params.monte_carlo_runs));
out_dir = create_results_folder(sprintf('sweep_%s', mode));
rows = table();

fprintf('Scenario sweep: %d scenarios, %d protocols, %d runs each.\n', ...
    numel(scenarios), numel(protocols), run_count);

for sidx = 1:numel(scenarios)
    params = apply_scenario(base_params, scenarios(sidx));
    fprintf('Scenario %d/%d: %s\n', sidx, numel(scenarios), scenarios(sidx).name);
    
    for pidx = 1:numel(protocols)
        protocol_name = protocols{pidx};
        run_results = cell(run_count, 1);
        for run_id = 1:run_count
            seed = params.seed + 10000 * sidx + 100 * pidx + run_id;
            run_results{run_id} = run_protocol(protocol_name, params, seed);
        end
        summary = summarize_runs(run_results, params);
        rows = [rows; table( ...
            string(scenarios(sidx).name), string(protocol_name), ...
            params.field.xm, params.field.ym, params.n, ...
            string(params.field.shape), string(params.sink.placement), ...
            summary.first_dead_mean, summary.half_dead_mean, summary.all_dead_mean, ...
            summary.final_packets_bs_mean, summary.final_alive_mean, summary.final_residual_energy_mean, ...
            'VariableNames', {'Scenario','Protocol','Xm','Ym','Nodes','Shape','Sink','FND','HND','AND','Packets_BS','Alive_Final','Residual_Energy'})]; %#ok<AGROW>
    end
end

sweep.table = rows;
sweep.scenarios = scenarios;
sweep.mode = mode;
sweep.output_folder = out_dir;

writetable(rows, fullfile(out_dir, 'scenario_sweep.csv'));
save(fullfile(out_dir, 'scenario_sweep.mat'), 'sweep', 'base_params');
disp(rows);
fprintf('Scenario sweep results saved in %s\n', fullfile(pwd, out_dir));
end
