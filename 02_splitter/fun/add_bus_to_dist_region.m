function mpc = add_bus_to_dist_region(mpc, N_region, bus, fieldnames)
    if nargin == 3
        global NAME_FOR_AUX_FIELD
        name = NAME_FOR_AUX_FIELD;
    elseif nargin == 4
        name = fieldnames.NAME_FOR_AUX_FIELD;
    end
    if N_region > 0
        check_number_of_distribution_system(mpc, N_region);
    end
    N_region = N_region + 1;
    buses = mpc.(name){N_region};
    
    % add new bus
    buses(end+1) = bus;
    mpc.(name){N_region} = buses;
end