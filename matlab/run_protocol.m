function results = run_protocol(protocol_name, params, seed)
%RUN_PROTOCOL Dispatch one protocol simulation.

switch upper(protocol_name)
    case 'LEACH'
        results = protocol_leach(params, seed);
    case 'EDD_LEACH'
        results = protocol_edd_leach(params, seed);
    case 'AERT_UC'
        results = protocol_aert_uc(params, seed);
    case 'AWARE_UC'
        results = protocol_aware_uc(params, seed);
    case 'SEP'
        results = protocol_sep(params, seed);
    otherwise
        error('Unknown protocol: %s', protocol_name);
end
end
