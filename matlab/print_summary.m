function print_summary(all_results, params)
%PRINT_SUMMARY Print compact protocol comparison to MATLAB console.

fprintf('\n%-12s %-12s %-12s %-12s %-14s %-14s\n', ...
    'Protocol', 'FND', 'HND', 'AND', 'Packets_BS', 'Alive_Final');
fprintf('%s\n', repmat('-', 1, 82));

for i = 1:numel(params.protocols)
    name = params.protocols{i};
    s = all_results.(name).summary;
    fprintf('%-12s %-12.1f %-12.1f %-12.1f %-14.1f %-14.1f\n', ...
        name, s.first_dead_mean, s.half_dead_mean, s.all_dead_mean, ...
        s.final_packets_bs_mean, s.final_alive_mean);
end
fprintf('\n');
end
