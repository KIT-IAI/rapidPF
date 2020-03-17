function mpc = add_consensus_information(mpc, tab, names)
% add_consensus_information
%
%   `copy the declaration of the function in here (leave the ticks unchanged)`
%
%   _describe what the function does in the following line_
%
%   # Markdown formatting is supported
%   Equations are possible to, e.g $a^2 + b^2 = c^2$.
%   So are lists:
%   - item 1
%   - item 2
%   ```matlab
%   function y = square(x)
%       x^2
%   end
%   ```
%   See also: [run_case_file_splitter](run_case_file_splitter.md)

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

function tab_out = add_consensus_information_core(mpc, tab_in, names)
    Nconn = height(tab_in);
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
    end
    tab_out = table(orig_sys, copy_sys, orig_bus_local, copy_bus_local);
end