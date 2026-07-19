function results = protocol_sep(params, seed)
%PROTOCOL_SEP Stable Election Protocol baseline in the shared simulator.

nodes = init_network(params, seed);
results = empty_results(params, 'SEP');
n = params.n;
p = params.cluster_head_probability;
m = 0.1;
a = 1;

advanced_count = max(1, round(m * n));
advanced_ids = 1:advanced_count;
nodes.E(advanced_ids) = params.initial_energy * (1 + a);

pnrm = p / (1 + a * m);
padv = p * (1 + a) / (1 + a * m);
epoch_nrm = max(1, round(1 / pnrm));
epoch_adv = max(1, round(1 / padv));

for r = 0:params.rounds
    params.sink = get_round_sink(params, r);
    alive_ids = find(nodes.E > 0);
    dead = n - numel(alive_ids);
    results.dead(r + 1) = dead;
    results.alive(r + 1) = numel(alive_ids);
    results.residual_energy(r + 1) = sum(max(nodes.E, 0));
    results = update_milestones(results, r, dead, n);
    
    if isempty(alive_ids)
        continue;
    end
    
    ch_ids = [];
    for idx = 1:numel(alive_ids)
        id = alive_ids(idx);
        is_advanced = id <= advanced_count;
        if is_advanced
            prob = padv;
            epoch = epoch_adv;
        else
            prob = pnrm;
            epoch = epoch_nrm;
        end
        
        if (r - nodes.last_ch_round(id)) >= epoch
            denom = max(eps, 1 - prob * mod(r, epoch));
            threshold = prob / denom;
            if rand < threshold
                ch_ids(end + 1, 1) = id; %#ok<AGROW>
            end
        end
    end
    
    if isempty(ch_ids)
        [~, best_idx] = max(nodes.E(alive_ids));
        ch_ids = alive_ids(best_idx);
    end
    
    nodes.last_ch_round(ch_ids) = r;
    nodes.ch_count(ch_ids) = nodes.ch_count(ch_ids) + 1;
    results.cluster_heads(r + 1) = numel(ch_ids);
    
    member_ids = setdiff(alive_ids, ch_ids);
    [assignments, distances] = nearest_cluster_heads(nodes, member_ids, ch_ids);
    
    for i = 1:numel(member_ids)
        member_id = member_ids(i);
        ch_id = assignments(i);
        tx = radio_tx_energy(distances(i), params.packet_bits, params.energy);
        rx = radio_rx_energy(params.packet_bits, params.energy, true);
        if nodes.E(member_id) > tx && nodes.E(ch_id) > rx
            nodes.E(member_id) = nodes.E(member_id) - tx;
            nodes.E(ch_id) = nodes.E(ch_id) - rx;
            results.packets_to_ch(r + 1) = results.packets_to_ch(r + 1) + 1;
        else
            nodes.E(member_id) = max(0, nodes.E(member_id) - tx);
            nodes.E(ch_id) = max(0, nodes.E(ch_id) - rx);
        end
    end
    
    for i = 1:numel(ch_ids)
        ch_id = ch_ids(i);
        if nodes.E(ch_id) <= 0
            continue;
        end
        d_bs = dist_to_sink(nodes, params, ch_id);
        tx = radio_tx_energy(d_bs, params.packet_bits, params.energy) ...
            + params.energy.EDA * params.packet_bits;
        if nodes.E(ch_id) > tx
            nodes.E(ch_id) = nodes.E(ch_id) - tx;
            results.packets_to_bs(r + 1) = results.packets_to_bs(r + 1) + 1;
        else
            nodes.E(ch_id) = max(0, nodes.E(ch_id) - tx);
        end
    end
end
end

function [assignments, distances] = nearest_cluster_heads(nodes, member_ids, ch_ids)
assignments = zeros(numel(member_ids), 1);
distances = zeros(numel(member_ids), 1);
for i = 1:numel(member_ids)
    d = hypot(nodes.x(member_ids(i)) - nodes.x(ch_ids), nodes.y(member_ids(i)) - nodes.y(ch_ids));
    [distances(i), idx] = min(d);
    assignments(i) = ch_ids(idx);
end
end
