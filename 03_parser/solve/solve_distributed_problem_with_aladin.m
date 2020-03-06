function [xsol, xsol_stacked, mpc_sol] = solve_distributed_problem_with_aladin(mpc, problem, names, opts) 
    if nargin == 3
        opts = [];
    end
    [sol, timers] = run_ALADINnew(problem, opts);
    xsol = vertcat(sol.xxOpt{:});
    [xsol, xsol_stacked] = deal_solution(xsol, mpc, names); 
    
    %% numerical solution back to matpower casefile
    iter          =  size(sol.iter.logg.X, 1); % number of iteration
    elapsed_time  =  timers.totTime;
    alg           =  'ALADIN';
    mpc_sol       =  back_to_mpc(mpc, xsol, elapsed_time, iter, alg);
end