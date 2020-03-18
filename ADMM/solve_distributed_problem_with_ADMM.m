function xsol = solve_distributed_problem_with_ADMM(problem, params)
% solve the distributed problem
    max_iter           = params.max_iter;
    tol                = params.tol;
    rou                = params.rou;
    AA                 = problem.AA;
    b                  = problem.b;
    state              = problem.state;
    X                  = problem.zz0;
    % lamb_i initialize
    lam0               = problem.lam0;
    N_regions          = size(X,1);
    Lambda             = {};
    for i = 1:N_regions
        Lambda{i} = lam0;
    end

    % ADMM - consensus form
    for i = 1:max_iter
        fprintf('iteration = %d\n', i);
        % #1 solve the decoupled NLPs & #4 dual update
        [Y, Lambda] = solve_decoupled_NLPs(problem, X, Lambda, rou);
        % #2 terminate?
        [bool, violation] = check_terminal_condition(Y, AA, tol);
        if bool
            xsol = Y;
            return;
        else
            fprintf('norm of violation = %f\n', violation);
        end
        % #3 solve the centralized QP
        X = solve_centralized_QP(state,X,Y,Lambda,rou,AA,b);
    end
    xsol = [];
end

function [Y, Lambda] = solve_decoupled_NLPs(problem, X, Lambda, rou)
% solve decoupled NLPs for all regions
    global hi gi
    costs              = problem.locFuns.ffi;
    equalities         = problem.locFuns.ggi;
    inequalities       = problem.locFuns.hhi;
    AA                 = problem.AA;
    N_regions          = size(X,1);
    %options = optimoptions(@fminunc,'Display','iter','Algorithm','quasi-newton', 'MaxFunctionEvaluations', 10000);
    options = optimoptions(@fmincon,'Algorithm','interior-point','Display','off','MaxFunctionEvaluations', 10000);
    % solve decoupled NLPs
    for i = 1 : N_regions
        fprintf('Region N0.%d ...', i);

        fi       = costs{i};    
        gi       = equalities{i};
        if isempty(inequalities{1}(0))
            % fmincon fail when c(x) = []
            hi   = @(x)(zeros);
        else
            hi   = problem.locFuns.hhi{1};
        end
        Ai       = AA{i};
        xi       = X{i};
        lam_i    = Lambda{i};
        J        = @(yi)(fi(yi) + lam_i'*Ai*yi + penalty_term(yi,xi,Ai,rou));
        % solve a decoupled NLP of the current region
        yi       = fmincon(J,xi,[],[],[],[],[],[], @nonlinear_constraints,options);
        Y{i}     = yi;
        % dual upgrate
        Lambda{i}= lam_i + rou*Ai*(yi-xi);
        fprintf('converged!\n');    
    end
    clear global
end

function [bool, violation] = check_terminal_condition(Y, AA, tol)
% check whether the terminal condition fullfilled
    N_regions = size(Y,1);
    violation = zeros(size(AA{1},1),1);
    for i = 1 : N_regions
        violation = violation + AA{i}*Y{i};
    end
    violation = norm(violation);
    if violation <= tol
        bool = true;
    else
        bool = false;
    end
end

function X = solve_centralized_QP(state,X,Y,Lambda,rou,AA,b)
    N_regions = size(Y,1);
    N_states  = get_number_of_state(state);
    
    x   = sym('x_',[sum(N_states),1]);
    J   = 0;
    n   = 1;
    % structure the cost function
    for i=1:N_regions
        m = n + N_states(i) - 1;
        J = J + penalty_term(x(n:m),Y{i},AA{i},rou) ...
              - Lambda{i}'*AA{i}*x(n:m);
        n = n + N_states(i);
    end
    J = matlabFunction(J,'Vars',{x});
    Aeq = cell2mat(AA');  % equality constraints
    x0  = cell2mat(X);
    options = optimoptions(@fmincon,'Display','off','MaxFunctionEvaluations', 10000);

    x_stacked  = fmincon(@(x)J(x),x0,[],[],Aeq,b,[],[],[],options);
    X   = mat2cell(x_stacked, N_states);
end

function [c, ceq] = nonlinear_constraints(x)
% nonlinear constraints
global hi gi
c   = hi(x);
ceq = gi(x);
end

function n = penalty_term(x,y,A,rou)
    n = rou/2*norm(A*(x-y))^2;
end

function N_states = get_number_of_state(X)
% get the numbers of states in each region
    N_regions = size(X,1);
    N_states = [];
    for i = 1:N_regions
        N_states(i) = size(X{i},1);
    end
end
