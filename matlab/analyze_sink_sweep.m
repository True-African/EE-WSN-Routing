function analysis = analyze_sink_sweep(sweep_csv)
%ANALYZE_SINK_SWEEP Create publication-ready tables and plots.

if nargin < 1
    sweep_csv = latest_result_file('sweep_sink_*', 'scenario_sweep.csv');
end

T = readtable(sweep_csv);
[parent_dir, ~, ~] = fileparts(sweep_csv);
out_dir = create_analysis_folder(parent_dir, 'analysis_sink');

fprintf('Analyzing sink sweep: %s\n', sweep_csv);
fprintf('Analysis output folder: %s\n', out_dir);

tables = struct();
tables.protocol_summary = groupsummary(T, 'Protocol', 'mean', ...
    {'FND','HND','AND','Packets_BS','Alive_Final','Residual_Energy'});
tables.sink_protocol_summary = groupsummary(T, {'Sink','Protocol'}, 'mean', ...
    {'FND','HND','AND','Packets_BS','Alive_Final','Residual_Energy'});
tables.shape_protocol_summary = groupsummary(T, {'Shape','Protocol'}, 'mean', ...
    {'FND','HND','AND','Packets_BS','Alive_Final','Residual_Energy'});
tables.improvements = build_aert_improvement_table(T);
tables.heatmap_packets_vs_leach = pivot_improvement(tables.improvements, 'AERT_vs_LEACH_Packets_pct');
tables.heatmap_packets_vs_edd = pivot_improvement(tables.improvements, 'AERT_vs_EDD_Packets_pct');
tables.heatmap_fnd_vs_leach = pivot_improvement(tables.improvements, 'AERT_vs_LEACH_FND_pct');
tables.heatmap_and_vs_leach = pivot_improvement(tables.improvements, 'AERT_vs_LEACH_AND_pct');

write_analysis_tables(tables, out_dir);
make_sink_plots(tables, out_dir);

analysis.source_csv = sweep_csv;
analysis.output_folder = out_dir;
analysis.tables = tables;
save(fullfile(out_dir, 'sink_sweep_analysis.mat'), 'analysis');

fprintf('Done. Publication tables and plots saved in %s\n', out_dir);
end

function out_dir = create_analysis_folder(parent_dir, label)
stamp = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
out_dir = fullfile(parent_dir, sprintf('%s_%s', label, stamp));
mkdir(out_dir);
end

function out = build_aert_improvement_table(T)
scenarios = unique(T.Scenario, 'stable');
out = table();

for i = 1:numel(scenarios)
    S = T(strcmp(T.Scenario, scenarios{i}), :);
    A = S(strcmp(S.Protocol, 'AERT_UC'), :);
    L = S(strcmp(S.Protocol, 'LEACH'), :);
    E = S(strcmp(S.Protocol, 'EDD_LEACH'), :);
    
    out = [out; table( ...
        string(scenarios{i}), string(A.Shape), string(A.Sink), A.Xm, A.Ym, A.Nodes, ...
        A.FND, L.FND, E.FND, pct(A.FND, L.FND), pct(A.FND, E.FND), ...
        A.HND, L.HND, E.HND, pct(A.HND, L.HND), pct(A.HND, E.HND), ...
        A.AND, L.AND, E.AND, pct(A.AND, L.AND), pct(A.AND, E.AND), ...
        A.Packets_BS, L.Packets_BS, E.Packets_BS, ...
        pct(A.Packets_BS, L.Packets_BS), pct(A.Packets_BS, E.Packets_BS), ...
        A.Residual_Energy, L.Residual_Energy, E.Residual_Energy, ...
        'VariableNames', {'Scenario','Shape','Sink','Xm','Ym','Nodes', ...
        'AERT_FND','LEACH_FND','EDD_FND','AERT_vs_LEACH_FND_pct','AERT_vs_EDD_FND_pct', ...
        'AERT_HND','LEACH_HND','EDD_HND','AERT_vs_LEACH_HND_pct','AERT_vs_EDD_HND_pct', ...
        'AERT_AND','LEACH_AND','EDD_AND','AERT_vs_LEACH_AND_pct','AERT_vs_EDD_AND_pct', ...
        'AERT_Packets_BS','LEACH_Packets_BS','EDD_Packets_BS', ...
        'AERT_vs_LEACH_Packets_pct','AERT_vs_EDD_Packets_pct', ...
        'AERT_Residual_Energy','LEACH_Residual_Energy','EDD_Residual_Energy'})]; %#ok<AGROW>
end
end

function value = pct(a, b)
value = ((a - b) ./ b) * 100;
end

function P = pivot_improvement(improvements, metric_name)
P = groupsummary(improvements, {'Sink','Shape'}, 'mean', metric_name);
P.Properties.VariableNames{end} = metric_name;
end

function write_analysis_tables(tables, out_dir)
writetable(tables.protocol_summary, fullfile(out_dir, 'table_01_protocol_summary.csv'));
writetable(tables.sink_protocol_summary, fullfile(out_dir, 'table_02_sink_protocol_summary.csv'));
writetable(tables.shape_protocol_summary, fullfile(out_dir, 'table_03_shape_protocol_summary.csv'));
writetable(tables.improvements, fullfile(out_dir, 'table_04_aert_improvements_by_scenario.csv'));
writetable(tables.heatmap_packets_vs_leach, fullfile(out_dir, 'table_05_heatmap_packets_vs_leach.csv'));
writetable(tables.heatmap_packets_vs_edd, fullfile(out_dir, 'table_06_heatmap_packets_vs_edd.csv'));
writetable(tables.heatmap_fnd_vs_leach, fullfile(out_dir, 'table_07_heatmap_fnd_vs_leach.csv'));
writetable(tables.heatmap_and_vs_leach, fullfile(out_dir, 'table_08_heatmap_and_vs_leach.csv'));
end

function make_sink_plots(tables, out_dir)
set(0, 'DefaultFigureColor', 'w');

plot_grouped_bar(tables.sink_protocol_summary, 'Sink', 'Protocol', 'mean_Packets_BS', ...
    'Average Packets Delivered by Sink Placement', 'Packets delivered to BS', ...
    fullfile(out_dir, 'fig_01_packets_by_sink.png'));

plot_grouped_bar(tables.sink_protocol_summary, 'Sink', 'Protocol', 'mean_FND', ...
    'Average First Node Death by Sink Placement', 'Round', ...
    fullfile(out_dir, 'fig_02_fnd_by_sink.png'));

plot_grouped_bar(tables.sink_protocol_summary, 'Sink', 'Protocol', 'mean_HND', ...
    'Average Half Node Death by Sink Placement', 'Round', ...
    fullfile(out_dir, 'fig_03_hnd_by_sink.png'));

plot_grouped_bar(tables.sink_protocol_summary, 'Sink', 'Protocol', 'mean_AND', ...
    'Average All Node Death by Sink Placement', 'Round', ...
    fullfile(out_dir, 'fig_04_and_by_sink.png'));

plot_heatmap(tables.heatmap_packets_vs_leach, 'AERT_vs_LEACH_Packets_pct', ...
    'AERT-UC Packet Improvement over LEACH (%)', fullfile(out_dir, 'fig_05_heatmap_packets_vs_leach.png'));

plot_heatmap(tables.heatmap_packets_vs_edd, 'AERT_vs_EDD_Packets_pct', ...
    'AERT-UC Packet Improvement over EDD-LEACH (%)', fullfile(out_dir, 'fig_06_heatmap_packets_vs_edd.png'));
end

function plot_grouped_bar(T, x_name, group_name, y_name, chart_title, y_label, file_path)
x_values = unique(string(T.(x_name)), 'stable');
group_values = unique(string(T.(group_name)), 'stable');
Y = zeros(numel(x_values), numel(group_values));

for i = 1:numel(x_values)
    for j = 1:numel(group_values)
        row = strcmp(string(T.(x_name)), x_values(i)) & strcmp(string(T.(group_name)), group_values(j));
        Y(i, j) = T.(y_name)(row);
    end
end

figure('Name', chart_title, 'Position', [100 100 1100 600]);
bar(categorical(x_values), Y, 'grouped');
disable_axes_toolbar(gca);
grid on;
ylabel(y_label);
title(chart_title);
legend(group_values, 'Interpreter', 'none', 'Location', 'northoutside', 'Orientation', 'horizontal');
set(gca, 'FontSize', 11);
exportgraphics(gcf, file_path, 'Resolution', 300);
end

function plot_heatmap(T, metric_name, chart_title, file_path)
sinks = unique(string(T.Sink), 'stable');
shapes = unique(string(T.Shape), 'stable');
Z = nan(numel(shapes), numel(sinks));

for i = 1:numel(shapes)
    for j = 1:numel(sinks)
        row = strcmp(string(T.Shape), shapes(i)) & strcmp(string(T.Sink), sinks(j));
        Z(i, j) = T.(metric_name)(row);
    end
end

figure('Name', chart_title, 'Position', [100 100 1050 550]);
imagesc(Z);
disable_axes_toolbar(gca);
colorbar;
colormap(parula);
xticks(1:numel(sinks));
xticklabels(sinks);
yticks(1:numel(shapes));
yticklabels(shapes);
xlabel('Sink placement');
ylabel('Field shape');
title(chart_title);
set(gca, 'FontSize', 11);

for i = 1:numel(shapes)
    for j = 1:numel(sinks)
        text(j, i, sprintf('%.1f', Z(i, j)), ...
            'HorizontalAlignment', 'center', 'Color', 'w', 'FontWeight', 'bold');
    end
end

exportgraphics(gcf, file_path, 'Resolution', 300);
end

function disable_axes_toolbar(ax)
if isprop(ax, 'Toolbar')
    ax.Toolbar.Visible = 'off';
end
end
