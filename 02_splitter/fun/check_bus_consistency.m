function bool = check_bus_consistency(mpc, N_region, bus)
    % check that bus belongs to passed region
    global NAME_FOR_REGION_FIELD
    buses_in_region = mpc.(NAME_FOR_REGION_FIELD){N_region};

    if any(buses_in_region == bus)
        bool = true;
    else
        bool = false;
        error('bus is not an element of the specified region.')
    end
end