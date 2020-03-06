function mpc = add_bus_to_dist_region(mpc, N_region, bus, names)
    name = names.regions.global_with_copies;
    if N_region > 0
        check_number_of_distribution_system(mpc, N_region, names);
    end
    N_region = N_region + 1;
    buses = mpc.(name){N_region};
    
    % add new bus
    buses(end+1) = bus;
    mpc.(name){N_region} = buses;
end