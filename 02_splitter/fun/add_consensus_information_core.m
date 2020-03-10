function tab_out = add_consensus_information_core(mpc, tab_in, names)
    Nconn = height(tab_in);
%     N_buses = cellfun(@(x)numel(x), mpc.(names.regions.global));
    case_files = mpc.(names.split);
    
    [orig_sys, orig_bus_local, copy_sys, copy_bus_local] = deal(zeros(Nconn, 1));
    
    for i = 1:Nconn
        orig_sys(i) = tab_in.from_sys(i);
        copy_sys(i) = tab_in.to_sys(i);
        orig_bus_local(i) = tab_in.from_bus(i);
        
        mpc_orig = case_files{orig_sys(i)};
        mpc_copy = case_files{copy_sys(i)};
        
        bus_number = mpc_orig.bus(orig_bus_local(i));
        copy_bus_local(i) = find(mpc_copy.bus(:, 1) == bus_number);
        
%         m = mpc.(names.split){copy_sys(i)};
%         bus = find(m.bus(:, 1) == orig_bus_local(i) + sum(N_buses(1:orig_sys(i)-1)))
%         copy_bus_local(i) = bus;
    end
    tab_out = table(orig_sys, copy_sys, orig_bus_local, copy_bus_local);
end