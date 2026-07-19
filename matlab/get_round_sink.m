function sink = get_round_sink(params, r)
%GET_ROUND_SINK Return static or mobile base-station position for a round.

sink = params.sink;
if ~isfield(params.sink, 'mobility') || ~params.sink.mobility.enabled
    return;
end

cx = 0.5 * params.field.xm;
cy = 0.5 * params.field.ym;
pattern = lower(params.sink.mobility.pattern);
period = max(1, params.sink.mobility.period_rounds);
phase = params.sink.mobility.phase;
t = 2 * pi * mod(r, period) / period + phase;

switch pattern
    case 'circle'
        radius = params.sink.mobility.radius_fraction * 0.5 * min(params.field.xm, params.field.ym);
        sink.x = cx + radius * cos(t);
        sink.y = cy + radius * sin(t);
    case 'horizontal'
        margin = 0.10 * params.field.xm;
        span = params.field.xm - 2 * margin;
        sink.x = margin + span * (0.5 + 0.5 * sin(t));
        sink.y = cy;
    case 'vertical'
        margin = 0.10 * params.field.ym;
        span = params.field.ym - 2 * margin;
        sink.x = cx;
        sink.y = margin + span * (0.5 + 0.5 * sin(t));
    otherwise
        error('Unknown sink mobility pattern: %s', params.sink.mobility.pattern);
end
end
