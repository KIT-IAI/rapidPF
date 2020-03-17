function mpc = add_connection_info_local(mpc, sys, tab, names)
% add_connection_info_local
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