function bool = check_dimension(ang, mag, p, q)
% check_dimension
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
    [data{1:4}] = deal(ang, mag, p, q);
    sizes = cellfun(@(x)size(x,1), data);
    if numel(unique(sizes)) == 1
        bool = true;
    else
        bool = false;
        error('inconsistent dimensions');
    end
end