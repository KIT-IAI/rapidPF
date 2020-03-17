function tab = update_connections(tab, i, Nshift)
% update_connections
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
    assert(i > 1, 'cannot update the master system.');
    
    to_be_deleted = [];
    
    for k = 1:height(tab)
        row = tab(k, :);
        from_sys = row.from_sys;
        to_sys = row.to_sys;
        assert(from_sys < to_sys, 'inconsistent ordering');
        
        if from_sys == 1 && to_sys == i
            to_be_deleted = [to_be_deleted; k];
        elseif from_sys == i
            tab.from_bus(k) = tab.from_bus(k) + Nshift;
            tab.from_sys(k) = 1;
        end
    end
    
    tab(to_be_deleted, :) = [];
end