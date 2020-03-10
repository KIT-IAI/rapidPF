function [from_bus, to_bus] = get_edge_dist_system(mpc, N_dist_system, names)
    NAME_FOR_REGION_FIELD = names.regions.global;
    
    if ~isfield(mpc, NAME_FOR_REGION_FIELD)
        error('The provided case file does not have a field `%s` for the regions', NAME_FOR_REGION_FIELD);
    end
    
    check_number_of_distribution_system(mpc, N_dist_system, names);
    
    [from_bus, to_bus] = get_edge_dist_system_no_checks(mpc, N_dist_system, names);
    
    check_bus_numbering(from_bus, to_bus);
%     check_bus_consistency(mpc, 1, from_bus, names);
%     check_bus_consistency(mpc, N_dist_system+1, to_bus, names); % +1 is necessary to account for transmission system
    
end

function [from_bus, to_bus] = get_edge_dist_system_no_checks(mpc, N, names)
    NAME_FOR_CONNECTIONS_FIELD = names.connections.global;
    edges = mpc.(NAME_FOR_CONNECTIONS_FIELD){N};
    
    from_bus = edges(1);
    to_bus = edges(2);
end

function check_bus_numbering(from_bus, to_bus)
    assert(from_bus < to_bus, 'something is wrong with the bus numbering');
end

