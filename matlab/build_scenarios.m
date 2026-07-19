function scenarios = build_scenarios(mode)
%BUILD_SCENARIOS Default scenario sweep for size, node count, shape, sink.

if nargin < 1
    mode = 'core';
end

switch lower(mode)
    case 'core'
        field_sizes = [100 100; 300 300];
        node_counts = 100;
        shapes = {'square', 'circle', 'triangle', 'mixed'};
        sink_placements = {'center'};
    case 'sink'
        field_sizes = [100 100; 200 200; 300 300];
        node_counts = [100 200];
        shapes = {'square', 'circle', 'triangle', 'mixed'};
        sink_placements = {'center', 'edge-top', 'edge-bottom', ...
            'edge-left', 'edge-right', 'corner', 'outside-top'};
    case 'full'
        field_sizes = [100 100; 200 200; 300 300; 100 150];
        node_counts = [100 200];
        shapes = {'square', 'circle', 'triangle', 'mixed'};
        sink_placements = {'center', 'edge-top', 'corner'};
    otherwise
        error('Unknown scenario mode: %s', mode);
end

idx = 0;
for f = 1:size(field_sizes, 1)
    for nidx = 1:numel(node_counts)
        for sidx = 1:numel(shapes)
            for pidx = 1:numel(sink_placements)
                idx = idx + 1;
                scenarios(idx).name = sprintf('%dx%d_%dn_%s_%s', ...
                    field_sizes(f, 1), field_sizes(f, 2), node_counts(nidx), ...
                    shapes{sidx}, sink_placements{pidx}); %#ok<AGROW>
                scenarios(idx).xm = field_sizes(f, 1); %#ok<AGROW>
                scenarios(idx).ym = field_sizes(f, 2); %#ok<AGROW>
                scenarios(idx).n = node_counts(nidx); %#ok<AGROW>
                scenarios(idx).shape = shapes{sidx}; %#ok<AGROW>
                scenarios(idx).sink_placement = sink_placements{pidx}; %#ok<AGROW>
            end
        end
    end
end
end
