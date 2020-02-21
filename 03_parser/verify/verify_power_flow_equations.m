function bool = verify_power_flow_equations(mpc)
    mpc = ext2int(mpc);
    Y = makeYbus(mpc);
    bool = verify_function(mpc, @(ang, mag, p, q)create_power_flow_equations(ang, mag, p, q, Y), 'power flow equations');
end

