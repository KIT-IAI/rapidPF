function check_for_line(mpc, from_bus, to_bus)
    [F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, ...
        RATE_C, TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
        ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
    from_buses = mpc.branch(:, F_BUS);
    to_buses = mpc.branch(:, T_BUS);
    assert(sum(find(from_buses == from_bus & to_buses == to_bus)) > 0, 'post_processing:check_for_line', 'Something is wrong with the added transformer branch')
end