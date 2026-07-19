function comparison = run_dynamic_bs_case()
%RUN_DYNAMIC_BS_CASE Compare center BS against a circular mobile BS.

base_params = default_params();
base_params.field.shape = 'square';
base_params.field.xm = 100;
base_params.field.ym = 100;
base_params.n = 100;
base_params.sink.x = 0.5 * base_params.field.xm;
base_params.sink.y = 0.5 * base_params.field.ym;
base_params.sink.placement = 'center';

protocols = base_params.protocols;
run_count = max(3, base_params.calibration_runs);
out_dir = create_results_folder('dynamic_bs');
rows = table();

cases = {'center_static', 'dynamic_circle'};
fprintf('Dynamic BS case: %d cases, %d protocols, %d runs each.\n', ...
    numel(cases), numel(protocols), run_count);

for cidx = 1:numel(cases)
    params = base_params;
    switch cases{cidx}
        case 'center_static'
            params.sink.mobility.enabled = false;
        case 'dynamic_circle'
            params.sink.mobility.enabled = true;
            params.sink.mobility.pattern = 'circle';
            params.sink.mobility.radius_fraction = 0.35;
            params.sink.mobility.period_rounds = 900;
    end
    
    for pidx = 1:numel(protocols)
        protocol_name = protocols{pidx};
        fprintf('Case %s, protocol %s...\n', cases{cidx}, protocol_name);
        run_results = cell(run_count, 1);
        
        for run_id = 1:run_count
            seed = params.seed + 50000 * cidx + 100 * pidx + run_id;
            run_results{run_id} = run_protocol(protocol_name, params, seed);
        end
        
        summary = summarize_runs(run_results, params);
        rows = [rows; table( ...
            string(cases{cidx}), string(protocol_name), ...
            params.field.xm, params.field.ym, params.n, ...
            string(params.field.shape), string(params.sink.placement), ...
            params.sink.mobility.enabled, string(params.sink.mobility.pattern), ...
            summary.first_dead_mean, summary.half_dead_mean, summary.all_dead_mean, ...
            summary.final_packets_bs_mean, summary.final_alive_mean, summary.final_residual_energy_mean, ...
            'VariableNames', {'Case','Protocol','Xm','Ym','Nodes','Shape','Sink','Dynamic_BS','Mobility','FND','HND','AND','Packets_BS','Alive_Final','Residual_Energy'})]; %#ok<AGROW>
    end
end

comparison.table = rows;
comparison.output_folder = out_dir;
comparison.description = "Center static BS versus circular mobile BS in a 100x100 square field.";

writetable(rows, fullfile(out_dir, 'dynamic_bs_comparison.csv'));
save(fullfile(out_dir, 'dynamic_bs_comparison.mat'), 'comparison', 'base_params');
disp(rows);
fprintf('Dynamic BS comparison saved in %s\n', fullfile(pwd, out_dir));
end
