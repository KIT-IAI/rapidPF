function problem = generate_distributed_problem_for_aladin(mpc, names, problem_type)
% generate_distributed_problem_for_aladin
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
    problem = generate_distributed_problem(mpc, names, problem_type);
    problem = add_aladin_specifics(problem, mpc, names);
    
    % problem = generate_distributed_problem_new(mpc, names, problem_type);
    % problem = add_aladin_specifics_new(problem, mpc, names);
end