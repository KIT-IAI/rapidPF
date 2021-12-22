function [xsol, xsol_stacked, logg] = solve_rapidPF_aladin(problem, mpc_split, option, names)
    % extract data from rapidPF problem
    x0      = problem.zz0;
    lam0    = problem.lam0;   
    Nregion = numel(x0);
    A       = horzcat(problem.AA{:});
    if iscell(problem.b)
        b = zeros(numel(lam0),1);
        for i = 1:Nregion
            b       = b + problem.b{i};
        end
    else
        b       = problem.b;
    end
    % initialize local NLP problem by extracting data from rapidPF problem
    nlps(Nregion,1)     = localNLP;
    for i = 1:Nregion
        Nx = numel(x0{i});
        % cost fun
        fi = problem.locFuns.ffi{i};% original local cost function
        gi = problem.sens.gg{i};% gradient of the local cost function
        hi = problem.sens.HH{i};% hessian  of the local cost function
        Ai = problem.AA{i};% consensus matrix for current region
        % residual
        if strcmp(option.nlp.solver,'lsqnonlin')
            ri  = problem.locFuns.rri{i};% residual function
            dri = problem.locFuns.dri{i};% gradient of residual function
        else
            ri  = [];
            dri = [];
        end
        
        % constraints
        if strcmp(option.problem_type,'feasibility')
            option.constrained = 'equality';
            con_eq    = problem.locFuns.ggi{i};            % equality constraints
            jac_eq    = problem.sens.JJac{i};            % jacobian matrix of equality constraints
        else
            con_eq    = [];            % equality constraints
            jac_eq    = [];            % jacobian matrix of equality constraints
        end
        con_ineq    = [];            % equality constraints
        jac_ineq    = [];            % jacobian matrix of equality constraints
        % problem solve by lsqnonlin - objective calculated by residual
        local_funs = originalFuns(fi, gi, hi, Ai, [], [], con_eq, jac_eq, con_ineq, jac_ineq);
        nlps(i)    = localNLP(local_funs,option.nlp,problem.llbx{i},problem.uubx{i});
    end
    % main alg
    [xopt,logg] = run_aladin_algorithm(nlps,x0,lam0,A,b,option);
    % check if half dim
    if strcmp(problem.dimension, 'half')
        % back to whole
        state_opt = back_to_whole(xopt, problem);
    else
        state_opt = xopt;
    end
    % reordering primal variable
    [xsol, xsol_stacked] = deal_solution(state_opt, mpc_split, names); 
end