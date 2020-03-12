function M = get_copy_bus_information(mpc, fieldnames)
    copy_buses_local = mpc.(fieldnames.copy_buses.local);
    connections_global = mpc.(fieldnames.connections.local);
    trans_copies = copy_buses_local{1};
    dist_copies = copy_buses_local(2:end);
    
    regions = mpc.(fieldnames.regions.global);
    N_regions = numel(regions);
    N_connections = N_regions - 1;
    
    [from_trans, from_dist] = deal(zeros(N_connections, 4));
    
    N_dist = 1;
    for i = 1:N_connections
        from_trans(i, 1:2) = [ 1 connections_global{i}(1) ];
        from_trans(i, 3:4) = [ N_dist + 1, dist_copies{N_dist} ];
        
        from_dist(i, 1:2) = [ N_dist + 1, connections_global{i}(2)];
        from_dist(i, 3:4) = [ 1, trans_copies(i)];
        N_dist = N_dist + 1;
    end
    
    M = [from_trans; from_dist];
end