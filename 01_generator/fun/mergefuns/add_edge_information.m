function mpc = add_edge_information(mpc, from_bus, to_bus, field_name)
    N = length(mpc.(field_name));
    mpc.(field_name){N + 1} = [from_bus, to_bus];
end