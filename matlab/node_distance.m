function d = node_distance(nodes, from_ids, to_ids)
%NODE_DISTANCE Pairwise distance between corresponding node id vectors.

d = hypot(nodes.x(from_ids) - nodes.x(to_ids), nodes.y(from_ids) - nodes.y(to_ids));
end
