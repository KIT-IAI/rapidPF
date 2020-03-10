function mpc = add_bus_to_trans_region(mpc, bus, names)
    mpc = add_bus_to_dist_region(mpc, 0, bus, names);
end