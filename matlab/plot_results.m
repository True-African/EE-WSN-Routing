function plot_results(all_results, params, out_dir)
%PLOT_RESULTS Create comparison plots for all protocols.

if nargin < 3
    out_dir = 'results';
end

rounds = (0:params.rounds)';
colors = lines(numel(params.protocols));

figure('Name', 'Alive Nodes');
hold on;
for i = 1:numel(params.protocols)
    name = params.protocols{i};
    plot(rounds, all_results.(name).summary.alive_mean, 'LineWidth', 1.8, 'Color', colors(i, :));
end
grid on;
xlabel('Round');
ylabel('Alive nodes');
title('Network lifetime');
legend(params.protocols, 'Interpreter', 'none', 'Location', 'southwest');
saveas(gcf, fullfile(out_dir, 'alive_nodes.png'));

figure('Name', 'Packets to Base Station');
hold on;
for i = 1:numel(params.protocols)
    name = params.protocols{i};
    plot(rounds, all_results.(name).summary.packets_bs_mean, 'LineWidth', 1.8, 'Color', colors(i, :));
end
grid on;
xlabel('Round');
ylabel('Cumulative packets');
title('Packets delivered to the base station');
legend(params.protocols, 'Interpreter', 'none', 'Location', 'northwest');
saveas(gcf, fullfile(out_dir, 'packets_to_bs.png'));

figure('Name', 'Residual Energy');
hold on;
for i = 1:numel(params.protocols)
    name = params.protocols{i};
    plot(rounds, all_results.(name).summary.residual_energy_mean, 'LineWidth', 1.8, 'Color', colors(i, :));
end
grid on;
xlabel('Round');
ylabel('Total residual energy (J)');
title('Residual network energy');
legend(params.protocols, 'Interpreter', 'none', 'Location', 'northeast');
saveas(gcf, fullfile(out_dir, 'residual_energy.png'));
end
