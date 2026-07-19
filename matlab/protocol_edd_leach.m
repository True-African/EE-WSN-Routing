function results = protocol_edd_leach(params, seed)
%PROTOCOL_EDD_LEACH Thesis-inspired threshold and alternate-path baseline.

nodes = init_network(params, seed);
nodes = pair_neighbors(nodes, params);
results = empty_results(params, 'EDD_LEACH');
n = params.n;
p = params.cluster_head_probability;
epoch = max(1, round(1 / p));
threshold = params.threshold.static_fraction * params.initial_energy;

for r = 0:params.rounds
    params.sink = get_round_sink(params, r);
    alive_ids = find(nodes.E > threshold);
    dead = n - numel(alive_ids);
    results.dead(r + 1) = dead;
    results.alive(r + 1) = numel(alive_ids);
    results.residual_energy(r + 1) = sum(max(nodes.E, 0));
    results = update_milestones(results, r, dead, n);
    
    if isempty(alive_ids)
        continue;
    end
    
    eligible = alive_ids((r - nodes.last_ch_round(alive_ids)) >= epoch);
    if isempty(eligible)
        eligible = alive_ids;
    end
    
    t = p / max(eps, 1 - p * mod(r, epoch));
    ch_ids = eligible(rand(numel(eligible), 1) < t);
    if isempty(ch_ids)
        [~, best_idx] = max(nodes.E(eligible));
        ch_ids = eligible(best_idx);
    end
    
    nodes.last_ch_round(ch_ids) = r;
    nodes.ch_count(ch_ids) = nodes.ch_count(ch_ids) + 1;
    results.cluster_heads(r + 1) = numel(ch_ids);
    
    member_ids = setdiff(alive_ids, ch_ids);
    [assignments, distances] = nearest_cluster_heads(nodes, member_ids, ch_ids);
    
    for i = 1:numel(member_ids)
        member_id = member_ids(i);
        ch_id = assignments(i);
        d = distances(i);
        tx = radio_tx_energy(d, params.packet_bits, params.energy);
        rx = radio_rx_energy(params.packet_bits, params.energy, true);
        
        if nodes.E(member_id) - tx <= threshold
            relay_id = choose_neighbor_relay(nodes, params, member_id, ch_id, threshold);
            if relay_id > 0
                relay_d = node_distance(nodes, member_id, relay_id);
                relay_tx = radio_tx_energy(relay_d, params.packet_bits, params.energy);
                relay_rx = radio_rx_energy(params.packet_bits, params.energy, false);
                relay_to_ch = node_distance(nodes, relay_id, ch_id);
                relay_forward = radio_tx_energy(relay_to_ch, params.packet_bits, params.energy);
                if nodes.E(member_id) > relay_tx && nodes.E(relay_id) > relay_rx + relay_forward
                    nodes.E(member_id) = nodes.E(member_id) - relay_tx;
                    nodes.E(relay_id) = nodes.E(relay_id) - relay_rx - relay_forward;
                    nodes.E(ch_id) = max(0, nodes.E(ch_id) - rx);
                    results.packets_to_ch(r + 1) = results.packets_to_ch(r + 1) + 1;
                    continue;
                end
            end
        end
        
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
        if nodes.E(ch_id) <= threshold
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
    
    nodes.mode = rotate_modes(nodes.mode, nodes.E, threshold);
end
end

function nodes = pair_neighbors(nodes, params)
n = numel(nodes.x);
paired = false(n, 1);
for i = 1:n
    if paired(i)
        continue;
    end
    candidates = find(~paired);
    candidates(candidates == i) = [];
    if isempty(candidates)
        continue;
    end
    d = hypot(nodes.x(i) - nodes.x(candidates), nodes.y(i) - nodes.y(candidates));
    [best_d, idx] = min(d);
    if best_d <= params.edd.cluster_range
        j = candidates(idx);
        nodes.neighbor(i) = j;
        nodes.neighbor(j) = i;
        nodes.mode(i) = 'A';
        nodes.mode(j) = 'S';
        paired([i j]) = true;
    end
end
end

function relay_id = choose_neighbor_relay(nodes, params, member_id, ch_id, threshold)
relay_id = nodes.neighbor(member_id);
if relay_id <= 0 || nodes.E(relay_id) <= threshold
    relay_id = 0;
    return;
end

direct_d = node_distance(nodes, member_id, ch_id);
relay_to_ch = node_distance(nodes, relay_id, ch_id);
if relay_to_ch >= direct_d
    relay_id = 0;
end
end

function modes = rotate_modes(modes, energy, threshold)
for i = 1:numel(modes)
    if energy(i) <= threshold
        modes(i) = 'S';
    elseif modes(i) == 'A'
        modes(i) = 'S';
    else
        modes(i) = 'A';
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
