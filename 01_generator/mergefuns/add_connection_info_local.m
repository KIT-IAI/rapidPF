function mpc = add_connection_info_local(mpc, sys, tab, names)
    name = names.connections.local;
    [rows, cols] = find_entries(tab, sys);
    
    type = string(zeros(numel(rows), 1));
    bus = zeros(numel(rows), 1);
    
    for k = 1:numel(rows)
        [t, b] = get_type_and_bus(tab, rows, cols, k);
        type(k) = t;
        bus(k) = b;
    end
    
    mpc.(name) = table(type, bus);
end

function [type, bus] = get_type_and_bus(tab, rows, cols, k)
    if cols(k) == 1
        type = 'from';
        bus = tab(rows(k), 'from_bus');
    elseif cols(k) == 2
        type = 'to';
        bus = tab(rows(k), 'to_bus');
    else
        error('I should not end up here...');
    end
    bus = bus.Variables;
end

function [rows, cols] = find_entries(tab, sys)
    [rows_, cols_] = find(table2array(tab(:, {'from_sys', 'to_sys'})) == sys);
    [rows, inds] = sort(rows_);
    cols = cols_(inds);
end