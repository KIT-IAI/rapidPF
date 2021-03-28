function [xsol, xsol_stacked, logg] = solve_distributed_problem_aladin(problem, mpc_split, option, names)
    % extract data from rapidPF problem
    A       = horzcat(problem.AA{:});
    b       = problem.b;
    x0      = problem.zz0;
    lam0    = problem.lam0;   
    Nregion = numel(x0);
    % initialize local NLP problem by extracting data from rapidPF problem
    nlps(Nregion,1)     = localNLP;
    for i = 1:Nregion
        if strcmp(option.nlp.solver,'lsqnonlin') 
            % problem solve by lsqnonlin - objective calculated by residual
            original_local_funs = originalFuns(problem.locFuns.ffi{i},...
                problem.sens.gg{i},problem.sens.HH{i}, problem.AA{i}, problem.locFuns.rri{i},...
                problem.locFuns.dri{i});
        else
            original_local_funs = originalFuns(problem.locFuns.ffi{i},...
                problem.sens.gg{i},problem.sens.HH{i}, problem.AA{i});
        end
        nlps(i)              = localNLP(original_local_funs,option.nlp,problem.llbx{i},problem.uubx{i});
    end
    % main alg
    [xopt,logg] = run_aladin_algorithm(nlps,x0,lam0,A,b,option); 
    % reordering primal variable
    [xsol, xsol_stacked] = deal_solution(xopt, mpc_split, names); 
end