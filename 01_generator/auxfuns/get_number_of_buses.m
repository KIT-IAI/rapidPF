function N = get_number_of_buses(mpc)
% get_number_of_buses
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
    N = size(mpc.bus, 1);
    % check 1:N numbering
    assert(sum(1:N) == sum(mpc.bus(:,1)), 'This code assumse 1:N numbering in buses. Please check.')
end