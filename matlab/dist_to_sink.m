function d = dist_to_sink(nodes, params, ids)
%DIST_TO_SINK Distance from node ids to the base station.

if nargin < 3
    ids = 1:numel(nodes.x);
end

d = hypot(nodes.x(ids) - params.sink.x, nodes.y(ids) - params.sink.y);
end
