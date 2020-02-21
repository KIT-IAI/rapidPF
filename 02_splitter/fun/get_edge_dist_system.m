function [from_bus, to_bus] = get_edge_dist_system(mpc, N_dist_system)
    global NAME_FOR_REGION_FIELD
    
    if ~isfield(mpc, NAME_FOR_REGION_FIELD)
        error('The provided case file does not have a field `%s` for the regions', NAME_FOR_REGION_FIELD);
    end
    
    check_number_of_distribution_system(mpc, N_dist_system);
    
    [from_bus, to_bus] = get_edge_dist_system_no_checks(mpc, N_dist_system);
    
    check_bus_numbering(from_bus, to_bus);
    check_bus_consistency(mpc, 1, from_bus);
    check_bus_consistency(mpc, N_dist_system+1, to_bus); % +1 is necessary to account for transmission system
    
end

function [from_bus, to_bus] = get_edge_dist_system_no_checks(mpc, N)
    global NAME_FOR_CONNECTIONS_FIELD
    edges = mpc.(NAME_FOR_CONNECTIONS_FIELD){N};
    
    from_bus = edges(1);
    to_bus = edges(2);
end

function bool = check_bus_numbering(from_bus, to_bus)
    if from_bus >= to_bus
        bool = false;
        error('something is wrong with the bus numbering');
    else
        bool = true;
    end
end

