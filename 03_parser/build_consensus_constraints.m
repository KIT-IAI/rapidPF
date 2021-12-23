function f = build_consensus_constraints(problem, x)
% build_consensus_constraints
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
    N_regions = numel(problem.AA);
    f = 0;
    sizes = cellfun(@(x)numel(x), problem.zz0);
    n = 0;
    state_dimension = problem.state_dimension;
    for i = 1:N_regions
        A = problem.AA{i};
        if iscell(x)
            y = x{i};
            
            if strcmp(state_dimension,'half')   % use half state as variables
                y = x{i}(problem.entries{i}.variable.stack); %only get variables
            end
        else
            y = x(n + (1:sizes(i)));
        end
        
        f = f + A*y;
        
        if strcmp(state_dimension,'half')   % use half state as variables
            f = f - problem.b{i};  % here b is not all zeros
        end
        
        n = n + sizes(i);
    end
end