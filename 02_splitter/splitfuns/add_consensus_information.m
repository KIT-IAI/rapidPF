function mpc = add_consensus_information(mpc, tab, names)
    consensus_1 = add_consensus_information_core(mpc, tab, names);
    tab_swapped = swap_table(tab);
    consensus_2 = add_consensus_information_core(mpc, tab_swapped, names);
    mpc.(names.consensus) = [consensus_1; consensus_2];
end

function tab_out = swap_table(tab_in)
    from_sys = tab_in.to_sys;
    to_sys = tab_in.from_sys;
    from_bus = tab_in.to_bus;
    to_bus = tab_in.from_bus;
    tab_out = table(from_sys, to_sys, from_bus, to_bus);
end