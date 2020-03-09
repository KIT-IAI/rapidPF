function tab = build_connection_table(connection_information)
    from_sys = connection_information(:, 1);
    to_sys = connection_information(:, 2);
    from_bus = connection_information(:, 3);
    to_bus = connection_information(:, 4);
    
    connections = [1:numel(from_sys)]';
    
    tab = table(from_sys, to_sys, from_bus, to_bus, 'RowNames', string(connections));
end