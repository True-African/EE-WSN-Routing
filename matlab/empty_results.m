function results = empty_results(params, protocol_name)
%EMPTY_RESULTS Allocate result vectors for one simulation run.

m = params.rounds + 1;
results.protocol = protocol_name;
results.dead = zeros(m, 1);
results.alive = zeros(m, 1);
results.cluster_heads = zeros(m, 1);
results.packets_to_ch = zeros(m, 1);
results.packets_to_bs = zeros(m, 1);
results.residual_energy = zeros(m, 1);
results.first_dead_round = NaN;
results.half_dead_round = NaN;
results.all_dead_round = NaN;
end
