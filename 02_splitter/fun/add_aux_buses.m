function mpc = add_aux_buses(mpc, names)
    NAME_FOR_REGION_FIELD = names.regions.global;
    NAME_FOR_AUX_FIELD = names.regions.global_with_copies;
    NAME_FOR_COPY_BUSES = names.copy_buses.local;
    
    N_dist_systems = numel(mpc.(NAME_FOR_REGION_FIELD)) - 1;
    mpc.(NAME_FOR_AUX_FIELD) = mpc.(NAME_FOR_REGION_FIELD);
    
    mpc.(NAME_FOR_COPY_BUSES) = cell(N_dist_systems + 1, 1);
    for N = 1:N_dist_systems
        [from_bus, to_bus] = get_edge_dist_system(mpc, N);
        
        % add from bus to current distribution system
        mpc = add_bus_to_dist_region(mpc, N, from_bus);
        dist_buses = mpc.(NAME_FOR_AUX_FIELD){1+N};
        mpc.(NAME_FOR_COPY_BUSES){N+1} = find_bus_entry(dist_buses, from_bus);
        
        % add aux bus to transmission system
        mpc = add_bus_to_trans_region(mpc, to_bus);
        trans_buses = mpc.(NAME_FOR_AUX_FIELD){1};
        mpc.(NAME_FOR_COPY_BUSES){1} = [mpc.(NAME_FOR_COPY_BUSES){1}; find_bus_entry(trans_buses, to_bus)];
    end
    check_number_of_buses(mpc, names);
end

function bus_entry = find_bus_entry(buses, bus_number)
    bus_entry = find(buses == bus_number);
end

function check_number_of_buses(mpc, names)
    NAME_FOR_REGION_FIELD = names.regions.global;
    NAME_FOR_AUX_FIELD = names.regions.global_with_copies;
    regions = mpc.(NAME_FOR_REGION_FIELD);
    aux_regions = mpc.(NAME_FOR_AUX_FIELD);
    
    trans_region = regions{1};
    dist_regions = regions(2:end);
    
    trans_aux_region = aux_regions{1};
    dist_aux_regions = aux_regions(2:end);
    
    if numel(dist_regions) == numel(dist_aux_regions)
        N_dist_systems = numel(dist_regions);
    else
        error('inconsistent number of distribution systems.');
    end
    if ~(numel(trans_aux_region) == numel(trans_region) + N_dist_systems)
        error('inconsistent number of buses in trans region')
    end
    for i = 1:N_dist_systems
        if ~(numel(dist_aux_regions{i}) == numel(dist_regions{i}) + 1)
            error('inconsistent number of buses in dist region %i, i');
        end
    end
end

