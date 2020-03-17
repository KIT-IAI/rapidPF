function [vang, vmag, pnet, qnet] = create_initial_condition(mpc, copy_buses)
% create_initial_condition
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
    if nargin == 1
        copy_buses = [];
    end
    [vang, vmag, pnet, qnet] = extract_results(mpc);
    
    if ~isempty(copy_buses)
        pnet(copy_buses) = [];
        qnet(copy_buses) = [];
    end
end