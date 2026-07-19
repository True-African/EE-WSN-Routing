function params = default_params()
%DEFAULT_PARAMS Shared parameters for WSN routing simulations.

params.field.xm = 100;
params.field.ym = 100;
params.field.shape = 'square';
params.sink.x = 0.5 * params.field.xm;
params.sink.y = 0.5 * params.field.ym;
params.sink.placement = 'center';
params.sink.mobility.enabled = false;
params.sink.mobility.pattern = 'circle';
params.sink.mobility.radius_fraction = 0.35;
params.sink.mobility.period_rounds = 900;
params.sink.mobility.phase = 0;

params.n = 100;
params.rounds = 4500;
params.packet_bits = 4000;
params.initial_energy = 0.5;
params.cluster_head_probability = 0.05;

params.energy.Eelec = 50e-9;
params.energy.Efs = 10e-12;
params.energy.Emp = 1.3e-15;
params.energy.EDA = 5e-9;
params.energy.d0 = sqrt(params.energy.Efs / params.energy.Emp);

params.threshold.static_fraction = 1e-4;
params.threshold.risk_multiplier = 1.8;
params.threshold.min_fraction = 1e-4;

params.edd.cluster_range = 20;

params.aert.target_ch_fraction = 0.09;
params.aert.min_competition_radius = 8;
params.aert.max_competition_radius = 28;
params.aert.relay_saving_margin = 0.04;
params.aert.member_forward_weight = 0.20;
params.aert.load_balance_weight = 0.40;
params.aert.weights.energy = 0.32;
params.aert.weights.sink_distance = 0.22;
params.aert.weights.density = 0.18;
params.aert.weights.fairness = 0.10;
params.aert.weights.availability = 0.18;

params.monte_carlo_runs = 30;
params.calibration_runs = 5;
params.seed = 20260412;

params.protocols = {'LEACH', 'SEP', 'EDD_LEACH', 'AWARE_UC'};
end
