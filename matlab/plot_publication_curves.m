function plot_publication_curves(all_results, params, out_dir)
%PLOT_PUBLICATION_CURVES Publication-style per-round comparison curves.

if nargin < 3
    out_dir = 'results';
end

rounds = (0:params.rounds)';
protocols = params.protocols;
colors = protocol_colors(protocols);

plot_curve(rounds, all_results, protocols, colors, 'packets_bs_mean', ...
    'Packets delivered to the base station', 'Round', 'Cumulative packets', ...
    fullfile(out_dir, 'pub_packets_to_bs_curve.png'));

plot_curve(rounds, all_results, protocols, colors, 'alive_mean', ...
    'Alive nodes over simulation rounds', 'Round', 'Alive nodes', ...
    fullfile(out_dir, 'pub_alive_nodes_curve.png'));

plot_curve(rounds, all_results, protocols, colors, 'dead_mean', ...
    'Dead nodes over simulation rounds', 'Round', 'Dead nodes', ...
    fullfile(out_dir, 'pub_dead_nodes_curve.png'));

plot_curve(rounds, all_results, protocols, colors, 'residual_energy_mean', ...
    'Residual network energy', 'Round', 'Total residual energy (J)', ...
    fullfile(out_dir, 'pub_residual_energy_curve.png'));
end

function plot_curve(rounds, all_results, protocols, colors, field_name, chart_title, x_label, y_label, file_path)
figure('Name', chart_title, 'Position', [100 100 1200 720]);
hold on;

for i = 1:numel(protocols)
    name = protocols{i};
    y = all_results.(name).summary.(field_name);
    plot(rounds, y, 'LineWidth', 2.4, 'Color', colors(i, :));
end

grid on;
box on;
xlabel(x_label, 'FontSize', 15);
ylabel(y_label, 'FontSize', 15);
title(chart_title, 'FontSize', 15, 'FontWeight', 'bold');
legend(protocols, 'Interpreter', 'none', 'Location', 'northwest', ...
    'FontSize', 12, 'Box', 'on');
set(gca, 'FontSize', 13, 'LineWidth', 1.0);

ax = gca;
if isprop(ax, 'Toolbar')
    ax.Toolbar.Visible = 'off';
end

exportgraphics(gcf, file_path, 'Resolution', 300);
end

function colors = protocol_colors(protocols)
colors = zeros(numel(protocols), 3);
for i = 1:numel(protocols)
    switch upper(protocols{i})
        case 'LEACH'
            colors(i, :) = [0.0000 0.4470 0.7410];
        case 'EDD_LEACH'
            colors(i, :) = [0.8500 0.3250 0.0980];
        case 'AERT_UC'
            colors(i, :) = [0.9290 0.6940 0.1250];
        case 'AWARE_UC'
            colors(i, :) = [0.9290 0.6940 0.1250];
        case 'SEP'
            colors(i, :) = [0.4940 0.1840 0.5560];
        otherwise
            colors(i, :) = lines(1);
    end
end
end
