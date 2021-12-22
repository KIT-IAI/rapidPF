function state = back_to_whole(xsol, problem)
% back_to_mpc
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

% get numbers of variables in each region
    Nregion = numel(problem.entries);
    state = cell(Nregion, 1);
    n_x = 0;

    for i = 1:Nregion
        % entries of variable in region i
        entries_variable = problem.entries{i}.variable.stack;
        % num of variables in region i
        n_variable = numel(problem.entries{i}.variable.stack);
        
        state{i} = problem.state_0{i};
        state{i}(entries_variable) = xsol(n_x + (1: n_variable));
        n_x = n_x + n_variable;
    end

    % stack state
    state = vertcat(state{:});
end