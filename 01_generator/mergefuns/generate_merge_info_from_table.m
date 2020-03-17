function info = generate_merge_info_from_table(i, tab, fields_to_merge)
% generate_merge_info_from_table
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
    rows = find((tab.from_sys == i & tab.to_sys == 1) | (tab.to_sys == i & tab.from_sys == 1));
    info = generate_merge_info(tab.from_bus(rows), tab.to_bus(rows), tab.trafo_pars(rows), fields_to_merge); 
end