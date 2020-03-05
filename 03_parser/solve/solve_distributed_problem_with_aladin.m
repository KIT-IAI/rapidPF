function [xsol, xsol_stacked] = solve_distributed_problem_with_aladin_not_symbolic(mpc, problem, names, opts)
    NsubSys = numel(problem.AA);
%     [ffifun, hhifun, ggifun] = deal(cell(NsubSys, 1));
    
%     for i=1:NsubSys
%         [ffifun{i},hhifun{i},ggifun{i}] = deal( @(x)0*sum(x), @(x)[], matlabFunction(problem.ggi{i},'Vars',{problem.xx{i}}));
%     end    

    Ncons   = size(problem.AA{1},1);
    lam0    = 0.01*ones(Ncons,1);

    [xraw, loggAL] = run_ALADIN(problem.ffi,problem.ggi,problem.hhi,problem.AA,problem.xx0,lam0,problem.lbx,problem.ubx,problem.Sig,opts);
    
    
    [xsol, xsol_stacked] = deal_solution(xraw, mpc, names); 
end