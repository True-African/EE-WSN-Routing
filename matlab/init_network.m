function nodes = init_network(params, seed)
%INIT_NETWORK Create a reproducible random WSN deployment.

rng(seed, 'twister');
n = params.n;
[nodes.x, nodes.y] = deploy_nodes(params, n);
nodes.E = ones(n, 1) * params.initial_energy;
nodes.last_ch_round = -inf(n, 1);
nodes.ch_count = zeros(n, 1);
nodes.neighbor = zeros(n, 1);
nodes.mode = repmat('A', n, 1);
end

function [x, y] = deploy_nodes(params, n)
shape = lower(params.field.shape);
switch shape
    case {'square', 'rectangle', 'rectangular'}
        x = rand(n, 1) * params.field.xm;
        y = rand(n, 1) * params.field.ym;
    case 'circle'
        [x, y] = deploy_circle(params, n);
    case 'triangle'
        [x, y] = deploy_triangle(params, n);
    case 'mixed'
        [x, y] = deploy_mixed(params, n);
    otherwise
        error('Unknown deployment shape: %s', params.field.shape);
end
end

function [x, y] = deploy_circle(params, n)
radius = 0.5 * min(params.field.xm, params.field.ym);
theta = 2 * pi * rand(n, 1);
rho = radius * sqrt(rand(n, 1));
x = 0.5 * params.field.xm + rho .* cos(theta);
y = 0.5 * params.field.ym + rho .* sin(theta);
end

function [x, y] = deploy_triangle(params, n)
u = rand(n, 1);
v = rand(n, 1);
flip = u + v > 1;
u(flip) = 1 - u(flip);
v(flip) = 1 - v(flip);

v1 = [0, 0];
v2 = [params.field.xm, 0];
v3 = [0.5 * params.field.xm, params.field.ym];
x = v1(1) + u .* (v2(1) - v1(1)) + v .* (v3(1) - v1(1));
y = v1(2) + u .* (v2(2) - v1(2)) + v .* (v3(2) - v1(2));
end

function [x, y] = deploy_mixed(params, n)
% Mixed field: rectangular background, central circular region, upper triangle.
n_rect = round(0.45 * n);
n_circle = round(0.30 * n);
n_triangle = n - n_rect - n_circle;

rect_params = params;
rect_params.field.shape = 'square';
[x1, y1] = deploy_nodes(rect_params, n_rect);

circle_params = params;
circle_params.field.shape = 'circle';
[x2, y2] = deploy_nodes(circle_params, n_circle);

tri_params = params;
tri_params.field.shape = 'triangle';
[x3, y3] = deploy_nodes(tri_params, n_triangle);

x = [x1; x2; x3];
y = [y1; y2; y3];
end
