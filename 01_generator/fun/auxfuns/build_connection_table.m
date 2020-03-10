function tab = build_connection_table(connections, trafo_pars)
    N = size(connections, 1);
    
    from_sys = connections(:, 1);
    to_sys = connections(:, 2);
    from_bus = connections(:, 3);
    to_bus = connections(:, 4);
    
    if isstruct(trafo_pars)
        trafo_pars = repmat({trafo_pars}, N, 1);
        warning('Assuming the same transformer parameters for all connections. Please double-check.')
    else
        assert(numel(trafo_pars) == N, 'inconsistent number of transformer parameters.');
    end
    
    connections = [1:N]';
    
    tab = table(from_sys, to_sys, from_bus, to_bus, trafo_pars, 'RowNames', string(connections));
end