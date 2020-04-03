function mpc = add_copy_nodes(mpc, tab, names)
% add_copy_nodes
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

    N_connections = height(tab);
    N_systems = numel(mpc.(names.regions.global));
    N_buses = cellfun(@(x)numel(x), mpc.(names.regions.global));
    
    [copy_buses_global, copy_buses_local] = deal(cell(N_systems, 1));
    for i = 1:N_connections
        from_sys = tab.from_sys(i);
        to_sys = tab.to_sys(i);
        from_bus = tab.from_bus(i);
        to_bus = tab.to_bus(i);
        
        copy_buses_global{from_sys} = assign_global_entry(copy_buses_global{from_sys}, to_bus, to_sys, N_buses);
        copy_buses_global{to_sys} = assign_global_entry(copy_buses_global{to_sys}, from_bus, from_sys, N_buses);
        
        copy_buses_local{from_sys} = assign_local_entry(copy_buses_local{from_sys}, N_buses(from_sys));
        copy_buses_local{to_sys} = assign_local_entry(copy_buses_local{to_sys}, N_buses(to_sys));
    end
    
    check_size(copy_buses_global, mpc, tab, names)
    check_size(copy_buses_local, mpc, tab, names)
    
    for i = 1:N_systems
        copy_buses_global{i} = sort(copy_buses_global{i});
        copy_buses_local{i} = sort(copy_buses_local{i});
    end
    
    mpc.(names.copy_buses.global) = copy_buses_global;
    mpc.(names.copy_buses.local) = copy_buses_local;
end

function check_size(buses, mpc, tab, names)
    copy_buses = get_number_of_copy_nodes(mpc, tab, names);
    for i = 1:numel(copy_buses)
        assert(numel(buses{i}) == copy_buses{i}, 'inconsistent dimensions.')
    end
end

function copy_nodes = get_number_of_copy_nodes(mpc, tab, names)
    N_systems = numel(mpc.(names.regions.global));
    copy_nodes = cell(N_systems, 1);
    
    for i = 1:N_systems
        f = sum(tab.from_sys == i);
        t = sum(tab.to_sys == i);
        copy_nodes{i} = f + t;
    end
end

function vec = assign_global_entry(vec, bus, sys, N)
    vec = [vec; bus + sum(N(1:sys-1))];
end

function vec = assign_local_entry(vec, N)
    if isempty(vec)
        vec = N + 1;
    else
        last = vec(end);
        vec = [ vec; last + 1 ];
    end
end
