function bool = check_number_of_distribution_system(mpc, N)
    global NAME_FOR_REGION_FIELD
    regions = mpc.(NAME_FOR_REGION_FIELD);
    N_all_dist_systems = numel(regions) - 1;
    if N <= 0 || N > N_all_dist_systems
        bool = false;
        error('invalid number of distribution system specified')
    end
    bool = true;
end