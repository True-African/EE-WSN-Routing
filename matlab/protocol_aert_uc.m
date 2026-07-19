function results = protocol_aert_uc(params, seed)
%PROTOCOL_AERT_UC Availability-aware Energy-Residual Threshold Uneven Clustering.
%
% Original model components:
% 1. Adaptive operating threshold from packet cost and mean residual energy.
% 2. Cluster-head score using energy, sink distance, density, fairness, availability.
% 3. Uneven competition radius to reduce hot-spot drain near the base station.
% 4. Energy-cost member assignment and CH relay when it saves energy.

nodes = init_network(params, seed);
results = empty_results(params, 'AERT_UC');
n = params.n;

for r = 0:params.rounds
    params.sink = get_round_sink(params, r);
    threshold = dynamic_threshold(nodes, params, r);
    alive_ids = find(nodes.E > threshold);
    dead = n - numel(alive_ids);
    results.dead(r + 1) = dead;
    results.alive(r + 1) = numel(alive_ids);
    results.residual_energy(r + 1) = sum(max(nodes.E, 0));
    results = update_milestones(results, r, dead, n);
    
    if isempty(alive_ids)
        continue;
    end
    
    ch_ids = select_aert_cluster_heads(nodes, params, alive_ids, threshold, r);
    if isempty(ch_ids)
        [~, best_idx] = max(nodes.E(alive_ids));
        ch_ids = alive_ids(best_idx);
    end
    
    nodes.last_ch_round(ch_ids) = r;
    nodes.ch_count(ch_ids) = nodes.ch_count(ch_ids) + 1;
    results.cluster_heads(r + 1) = numel(ch_ids);
    
    member_ids = setdiff(alive_ids, ch_ids);
    [assignments, distances] = assign_members_energy_cost(nodes, params, member_ids, ch_ids);
    ch_load = zeros(numel(ch_ids), 1);
    
    for i = 1:numel(member_ids)
        member_id = member_ids(i);
        ch_id = assignments(i);
        ch_idx = find(ch_ids == ch_id, 1);
        tx = radio_tx_energy(distances(i), params.packet_bits, params.energy);
        rx = radio_rx_energy(params.packet_bits, params.energy, true);
        
        if nodes.E(member_id) > tx + threshold && nodes.E(ch_id) > rx + threshold
            nodes.E(member_id) = nodes.E(member_id) - tx;
            nodes.E(ch_id) = nodes.E(ch_id) - rx;
            ch_load(ch_idx) = ch_load(ch_idx) + 1;
            results.packets_to_ch(r + 1) = results.packets_to_ch(r + 1) + 1;
        else
            relay_id = choose_aert_member_relay(nodes, params, member_id, ch_id, threshold);
            if relay_id > 0
                tx_member_relay = radio_tx_energy(node_distance(nodes, member_id, relay_id), params.packet_bits, params.energy);
                rx_relay = radio_rx_energy(params.packet_bits, params.energy, false);
                tx_relay_ch = radio_tx_energy(node_distance(nodes, relay_id, ch_id), params.packet_bits, params.energy);
                if nodes.E(member_id) > tx_member_relay + threshold ...
                        && nodes.E(relay_id) > rx_relay + tx_relay_ch + threshold ...
                        && nodes.E(ch_id) > rx + threshold
                    nodes.E(member_id) = nodes.E(member_id) - tx_member_relay;
                    nodes.E(relay_id) = nodes.E(relay_id) - rx_relay - tx_relay_ch;
                    nodes.E(ch_id) = nodes.E(ch_id) - rx;
                    ch_load(ch_idx) = ch_load(ch_idx) + 1;
                    results.packets_to_ch(r + 1) = results.packets_to_ch(r + 1) + 1;
                end
            end
        end
    end
    
    for i = 1:numel(ch_ids)
        ch_id = ch_ids(i);
        if nodes.E(ch_id) <= threshold
            continue;
        end
        [next_hop, tx_cost, relay_rx_cost] = choose_aert_ch_route(nodes, params, ch_id, ch_ids, threshold);
        aggregation_cost = params.energy.EDA * params.packet_bits;
        total_tx_cost = tx_cost + aggregation_cost;
        
        if next_hop == 0
            if nodes.E(ch_id) > total_tx_cost + threshold
                nodes.E(ch_id) = nodes.E(ch_id) - total_tx_cost;
                results.packets_to_bs(r + 1) = results.packets_to_bs(r + 1) + 1;
            end
        else
            if nodes.E(ch_id) > total_tx_cost + threshold && nodes.E(next_hop) > relay_rx_cost + threshold
                nodes.E(ch_id) = nodes.E(ch_id) - total_tx_cost;
                nodes.E(next_hop) = nodes.E(next_hop) - relay_rx_cost;
                results.packets_to_bs(r + 1) = results.packets_to_bs(r + 1) + 1;
            end
        end
    end
end
end

function threshold = dynamic_threshold(nodes, params, r)
alive = nodes.E(nodes.E > 0);
if isempty(alive)
    threshold = 0;
    return;
end

field_diag = hypot(params.field.xm, params.field.ym);
expected_d = 0.25 * field_diag;
packet_cost = radio_tx_energy(expected_d, params.packet_bits, params.energy) ...
    + radio_rx_energy(params.packet_bits, params.energy, true);
energy_pressure = 1 - mean(alive) / params.initial_energy;
round_pressure = r / max(1, params.rounds);
floor_threshold = params.threshold.min_fraction * params.initial_energy;

threshold = max(floor_threshold, params.threshold.risk_multiplier * packet_cost ...
    * (1 + 0.6 * energy_pressure + 0.4 * round_pressure));
threshold = min(threshold, 0.18 * params.initial_energy);
end

function ch_ids = select_aert_cluster_heads(nodes, params, alive_ids, threshold, r)
target_k = max(1, round(params.aert.target_ch_fraction * numel(alive_ids)));
score = cluster_head_score(nodes, params, alive_ids, threshold, r);
[~, order] = sort(score, 'descend');
ordered_ids = alive_ids(order);
sink_dist_all = dist_to_sink(nodes, params, ordered_ids);
max_sink_dist = max(sink_dist_all) + eps;

ch_ids = [];
for i = 1:numel(ordered_ids)
    candidate = ordered_ids(i);
    d_sink = dist_to_sink(nodes, params, candidate);
    radius = params.aert.min_competition_radius ...
        + (params.aert.max_competition_radius - params.aert.min_competition_radius) ...
        * (d_sink / max_sink_dist);
    if isempty(ch_ids)
        ch_ids = candidate;
    else
        d_to_selected = hypot(nodes.x(candidate) - nodes.x(ch_ids), nodes.y(candidate) - nodes.y(ch_ids));
        if all(d_to_selected > radius)
            ch_ids(end + 1, 1) = candidate; %#ok<AGROW>
        end
    end
    if numel(ch_ids) >= target_k
        break;
    end
end

if numel(ch_ids) < target_k
    missing = setdiff(ordered_ids, ch_ids, 'stable');
    take = min(target_k - numel(ch_ids), numel(missing));
    ch_ids = [ch_ids; missing(1:take)];
end
end

function score = cluster_head_score(nodes, params, ids, threshold, r)
w = params.aert.weights;
residual = normalize01(nodes.E(ids));
sink_distance = 1 - normalize01(dist_to_sink(nodes, params, ids));
density = normalize01(local_density(nodes, ids, params.edd.cluster_range));
fairness = normalize01(r - nodes.last_ch_round(ids));
availability = normalize01(max(0, nodes.E(ids) - threshold));

score = w.energy * residual ...
    + w.sink_distance * sink_distance ...
    + w.density * density ...
    + w.fairness * fairness ...
    + w.availability * availability;
end

function density = local_density(nodes, ids, radius)
density = zeros(numel(ids), 1);
for i = 1:numel(ids)
    d = hypot(nodes.x(ids(i)) - nodes.x(ids), nodes.y(ids(i)) - nodes.y(ids));
    density(i) = sum(d <= radius) - 1;
end
end

function [assignments, distances] = assign_members_energy_cost(nodes, params, member_ids, ch_ids)
assignments = zeros(numel(member_ids), 1);
distances = zeros(numel(member_ids), 1);
ch_load_estimate = zeros(numel(ch_ids), 1);

for i = 1:numel(member_ids)
    member_id = member_ids(i);
    d_member_ch = hypot(nodes.x(member_id) - nodes.x(ch_ids), nodes.y(member_id) - nodes.y(ch_ids));
    member_tx = radio_tx_energy(d_member_ch, params.packet_bits, params.energy);
    ch_to_sink = dist_to_sink(nodes, params, ch_ids);
    ch_forward = radio_tx_energy(ch_to_sink, params.packet_bits, params.energy);
    load_penalty = ch_load_estimate .* radio_rx_energy(params.packet_bits, params.energy, true);
    cost = member_tx ...
        + params.aert.member_forward_weight * ch_forward ...
        + params.aert.load_balance_weight * load_penalty;
    [~, idx] = min(cost);
    assignments(i) = ch_ids(idx);
    distances(i) = d_member_ch(idx);
    ch_load_estimate(idx) = ch_load_estimate(idx) + 1;
end
end

function relay_id = choose_aert_member_relay(nodes, params, member_id, ch_id, threshold)
alive_ids = find(nodes.E > threshold);
alive_ids(alive_ids == member_id) = [];
alive_ids(alive_ids == ch_id) = [];
if isempty(alive_ids)
    relay_id = 0;
    return;
end

direct_cost = radio_tx_energy(node_distance(nodes, member_id, ch_id), params.packet_bits, params.energy);
d_member = hypot(nodes.x(member_id) - nodes.x(alive_ids), nodes.y(member_id) - nodes.y(alive_ids));
d_ch = hypot(nodes.x(ch_id) - nodes.x(alive_ids), nodes.y(ch_id) - nodes.y(alive_ids));
relay_cost = radio_tx_energy(d_member, params.packet_bits, params.energy) ...
    + radio_rx_energy(params.packet_bits, params.energy, false) ...
    + radio_tx_energy(d_ch, params.packet_bits, params.energy);
relay_cost(nodes.E(alive_ids) <= relay_cost + threshold) = inf;
[best_cost, idx] = min(relay_cost);

if best_cost < direct_cost * (1 - params.aert.relay_saving_margin)
    relay_id = alive_ids(idx);
else
    relay_id = 0;
end
end

function [next_hop, tx_cost, relay_rx_cost] = choose_aert_ch_route(nodes, params, ch_id, ch_ids, threshold)
d_direct = dist_to_sink(nodes, params, ch_id);
direct_cost = radio_tx_energy(d_direct, params.packet_bits, params.energy);
next_hop = 0;
tx_cost = direct_cost;
relay_rx_cost = 0;

candidates = setdiff(ch_ids, ch_id);
if isempty(candidates)
    return;
end

d_candidate_sink = dist_to_sink(nodes, params, candidates);
closer = candidates(d_candidate_sink < d_direct);
if isempty(closer)
    return;
end

d_to_relay = hypot(nodes.x(ch_id) - nodes.x(closer), nodes.y(ch_id) - nodes.y(closer));
relay_tx = radio_tx_energy(d_to_relay, params.packet_bits, params.energy);
relay_rx = radio_rx_energy(params.packet_bits, params.energy, true);
relay_tx(nodes.E(closer) <= relay_rx + threshold) = inf;
[best_relay_tx, idx] = min(relay_tx);

if best_relay_tx < direct_cost * (1 - params.aert.relay_saving_margin)
    next_hop = closer(idx);
    tx_cost = best_relay_tx;
    relay_rx_cost = relay_rx;
end
end

function y = normalize01(x)
x = x(:);
span = max(x) - min(x);
if span < eps
    y = ones(size(x)) * 0.5;
else
    y = (x - min(x)) ./ span;
end
end
