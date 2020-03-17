function [x, x_stacked] = deal_solution(xsol, mpc, names)
% deal_solution
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
    buses_in_regions =  mpc.(names.regions.global);
    local_buses_in_regions = mpc.(names.regions.local);
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
        x_mat = make_to_array(x_temp, N_buses(i), N_copy_buses(i));
        % store results only for core nodes
        x{i} = x_mat(local_buses_in_regions{i}, :);
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