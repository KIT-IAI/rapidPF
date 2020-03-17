function tab = compare_results(x, y)
% compare_results
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
    assert(numel(x) == numel(y), 'inconsistent number of elements');
    dx = cell2mat(arrayfun(@(i)norm(x{i} - y{i}, Inf), 1:numel(x), 'UniformOutput', false))';
    regions = [1:numel(x)]';
    tab = table(regions, dx);
    tab.Properties.Description = 'Inf-norm of power flow solutions';
    tab.Properties.VariableNames = {'Regions', 'Inf-Norm of residual'};
end