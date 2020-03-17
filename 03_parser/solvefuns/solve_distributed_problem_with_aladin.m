function [xsol, xsol_stacked, mpc_sol] = solve_distributed_problem_with_aladin(mpc, problem, names, opts) 
% solve_distributed_problem_with_aladin
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
    if nargin == 3
        opts = [];
    end
    sol = run_ALADINnew(problem, opts);
    xsol = vertcat(sol.xxOpt{:});
    [xsol, xsol_stacked] = deal_solution(xsol, mpc, names); 
    
    %% numerical solution back to matpower casefile
    timers = sol.timers;
    iter          =  size(sol.iter.logg.X, 2); % number of iteration
    elapsed_time  =  timers.totTime - timers.setupT;
    alg           =  'ALADIN';
    mpc_sol       =  back_to_mpc(mpc, xsol, elapsed_time, iter, alg);
end