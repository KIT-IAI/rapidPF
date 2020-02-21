function bool = verify_bus_specifications(mpc)
    bool = verify_function(mpc, @(ang, mag, p, q)create_bus_specifications(ang, mag, p, q, mpc), 'bus specifications');
end

