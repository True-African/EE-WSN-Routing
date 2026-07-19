function params = apply_scenario(params, scenario)
%APPLY_SCENARIO Apply field, node count, shape, and sink settings.

params.field.xm = scenario.xm;
params.field.ym = scenario.ym;
params.field.shape = scenario.shape;
params.n = scenario.n;
mobility = params.sink.mobility;
params.sink = sink_from_placement(params, scenario.sink_placement);
params.sink.placement = scenario.sink_placement;
params.sink.mobility = mobility;
end

function sink = sink_from_placement(params, placement)
switch lower(placement)
    case 'center'
        sink.x = 0.5 * params.field.xm;
        sink.y = 0.5 * params.field.ym;
    case 'edge-top'
        sink.x = 0.5 * params.field.xm;
        sink.y = params.field.ym;
    case 'edge-bottom'
        sink.x = 0.5 * params.field.xm;
        sink.y = 0;
    case 'edge-left'
        sink.x = 0;
        sink.y = 0.5 * params.field.ym;
    case 'edge-right'
        sink.x = params.field.xm;
        sink.y = 0.5 * params.field.ym;
    case 'corner'
        sink.x = params.field.xm;
        sink.y = params.field.ym;
    case 'outside-top'
        sink.x = 0.5 * params.field.xm;
        sink.y = params.field.ym + 0.5 * params.field.ym;
    otherwise
        error('Unknown sink placement: %s', placement);
end
end
