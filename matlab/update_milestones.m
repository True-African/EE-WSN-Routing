function results = update_milestones(results, r, dead, n)
%UPDATE_MILESTONES Record first/half/all node death rounds once.

if isnan(results.first_dead_round) && dead >= 1
    results.first_dead_round = r;
end

if isnan(results.half_dead_round) && dead >= ceil(0.5 * n)
    results.half_dead_round = r;
end

if isnan(results.all_dead_round) && dead >= n
    results.all_dead_round = r;
end
end
