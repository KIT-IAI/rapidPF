function mpc = add_edge_information(mpc, from_bus, to_bus, field_name)
%     if from_bus >= to_bus
%         error('incorrect bus numbering.');
%     end

    N = length(mpc.(field_name));
    mpc.(field_name){N + 1} = [from_bus, to_bus];
end