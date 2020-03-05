function [xsol, xsol_stacked] = solve_distributed_problem_with_aladin(mpc, problem, names, opts)   
    sol = run_ALADINnew(problem, opts);
    xsol = vertcat(sol.xxOpt{:});
    [xsol, xsol_stacked] = deal_solution(xsol, mpc, names); 
end