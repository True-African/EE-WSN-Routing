function summary = summarize_runs(run_results, params)
%SUMMARIZE_RUNS Aggregate Monte Carlo curves and milestone metrics.

n_runs = numel(run_results);
m = params.rounds + 1;
dead = zeros(m, n_runs);
alive = zeros(m, n_runs);
packets_bs = zeros(m, n_runs);
packets_ch = zeros(m, n_runs);
cluster_heads = zeros(m, n_runs);
residual_energy = zeros(m, n_runs);
first_dead = zeros(n_runs, 1);
half_dead = zeros(n_runs, 1);
all_dead = zeros(n_runs, 1);

for i = 1:n_runs
    r = run_results{i};
    dead(:, i) = r.dead;
    alive(:, i) = r.alive;
    packets_bs(:, i) = cumsum(r.packets_to_bs);
    packets_ch(:, i) = cumsum(r.packets_to_ch);
    cluster_heads(:, i) = r.cluster_heads;
    residual_energy(:, i) = r.residual_energy;
    first_dead(i) = finite_or_default(r.first_dead_round, params.rounds);
    half_dead(i) = finite_or_default(r.half_dead_round, params.rounds);
    all_dead(i) = finite_or_default(r.all_dead_round, params.rounds);
end

summary.dead_mean = mean(dead, 2);
summary.alive_mean = mean(alive, 2);
summary.packets_bs_mean = mean(packets_bs, 2);
summary.packets_ch_mean = mean(packets_ch, 2);
summary.cluster_heads_mean = mean(cluster_heads, 2);
summary.residual_energy_mean = mean(residual_energy, 2);
summary.first_dead_mean = mean(first_dead);
summary.first_dead_std = std(first_dead);
summary.first_dead_ci95 = ci95(first_dead);
summary.half_dead_mean = mean(half_dead);
summary.half_dead_std = std(half_dead);
summary.half_dead_ci95 = ci95(half_dead);
summary.all_dead_mean = mean(all_dead);
summary.all_dead_std = std(all_dead);
summary.all_dead_ci95 = ci95(all_dead);
summary.final_packets_bs_mean = summary.packets_bs_mean(end);
final_packets_bs = packets_bs(end, :)';
summary.final_packets_bs_std = std(final_packets_bs);
summary.final_packets_bs_ci95 = ci95(final_packets_bs);
summary.final_alive_mean = summary.alive_mean(end);
final_alive = alive(end, :)';
summary.final_alive_std = std(final_alive);
summary.final_alive_ci95 = ci95(final_alive);
summary.final_residual_energy_mean = summary.residual_energy_mean(end);
final_residual_energy = residual_energy(end, :)';
summary.final_residual_energy_std = std(final_residual_energy);
summary.final_residual_energy_ci95 = ci95(final_residual_energy);
end

function value = finite_or_default(value, default_value)
if isnan(value)
    value = default_value;
end
end

function value = ci95(x)
x = x(:);
if numel(x) <= 1
    value = 0;
else
    value = 1.96 * std(x) / sqrt(numel(x));
end
end
