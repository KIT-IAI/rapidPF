function [x, x_stacked] = deal_solution(sol, mpc, names)
    xsol = full(sol.x);
    
    buses_in_regions =  mpc.(names.regions.global);
    copy_buses_in_regions = mpc.(names.copy_buses.global);
    
    N_buses = cellfun(@(x)numel(x), buses_in_regions);
    N_copy_buses = cellfun(@(x)numel(x), copy_buses_in_regions);
    N_regions = numel(buses_in_regions);
    
    [x, x_stacked] = deal(cell(N_regions, 1));
    
    N = 0;
    for i = 1:N_regions
        dim = 4*N_buses(i) + 2*N_copy_buses(i);
        x_temp = xsol(N + (1:dim));
        x_stacked{i} = x_temp;
        x{i} = make_to_array(x_temp, N_buses(i), N_copy_buses(i));
        N = N + dim;
    end
    
end

function y = make_to_array(x, N_bus, N_copy)
    dims = [ N_bus+N_copy, N_bus+N_copy, N_bus N_bus ];
    dims_cum = [0, cumsum(dims)];
    y = NaN*zeros(N_bus+N_copy, 4);
    
    for i = 1:numel(dims)
        y(1:dims(i), i) = x(dims_cum(i)+1:dims_cum(i+1));
    end
end