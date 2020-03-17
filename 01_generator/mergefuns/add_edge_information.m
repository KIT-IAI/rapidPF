function mpc = add_edge_information(mpc, from_bus, to_bus, field_name)
% add_edge_information
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
    N = length(mpc.(field_name));
    mpc.(field_name){N + 1} = [from_bus, to_bus];
end