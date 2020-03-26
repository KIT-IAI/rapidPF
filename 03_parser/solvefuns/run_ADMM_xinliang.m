function [xsol, violation, iter, loggX] = run_ADMM_xinliang(problem, params)
% solve the distributed problem
    max_iter           = params.max_iter;
    tol                = params.tol;
    rho                = params.rho;
    AA                 = problem.AA;
    b                  = problem.b;
    state              = problem.state;
    X                  = problem.zz0;
    A                  = horzcat(AA{:});  % Ax - b = 0, centralized
    N_states           = get_number_of_state(state);
    loggX              = [];
    %  initialize
    lam0               = problem.lam0;
    N_regions          = size(X,1);
    Lambda             = {};
    HQP                = []; % 

    % regularization only for components not involved in consensus and
    % project them back on x_k
    gam   = 1e-3;
    L     = diag(double(~sum(abs(A))));    
    for i = 1:N_regions
        Lambda{i} = lam0;
       % build H and A for ctr. QP    
        HQP = blkdiag(HQP, rho*AA{i}'*AA{i});
    end
    HQP   = HQP + gam*L'*L;

    % ADMM - consensus form
    for i = 1:max_iter
        fprintf('iteration = %d\n', i);
        xOld   = cell2mat(X);
        % #1 solve the decoupled NLPs 
        [Y, ~] = solve_decoupled_NLPs(problem, X, Lambda, rho);
        loggX  = [loggX Y'];
        % #2 terminate?
        [bool, violation(i)] = check_terminal_condition(Y, A, tol);
        if bool
            xsol = Y;
            iter = i;
            return;
        else
            fprintf('norm of violation = %f\n', violation(i));
        end
        % #3.1 old version to solve QP:
              % X    = solve_centralized_QP(state,X,Y,Lambda,rho,AA,b);#
        % #3.2 solve QP by KKT
        g=[];
        for j=1:N_regions
           g  = [g, - rho*Y{j}'*AA{j}'*AA{j}-Lambda{j}'*AA{j}];
        end
        % regularization only for components not involved in consensus and
        % project them back on x_k
        gQP   = g' - gam*L'*L*vertcat(Y{:});
        AQP   = A;
        bQP   = b; 
        x_stacked     = solve_centralized_QPnew(HQP,gQP,AQP,bQP);
        X     = mat2cell(x_stacked, N_states);
        % #4 lambda update
        for j = 1:N_regions
            Lambda{j} = Lambda{j} + rho*AA{j}*(Y{j}-X{j});
        end        
        % #5 update rule according to Guo 17 from remote point
        % currently rho update is not actived
        if norm(A*x_stacked,inf) > 0.9*norm(A*xOld,inf) && i > 1
%            rho = rho*1.025;
        end
    end
    xsol = X;
    iter = i;
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
    %options = optimoptions(@fmincon,'Algorithm','interior-point','Display','iter','MaxFunctionEvaluations', 10000);
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

function [bool, violation] = check_terminal_condition(Y, A, tol)
% check whether the terminal condition fullfilled
    y         = cell2mat(Y');
    violation = norm(A*y,inf);
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

function x_stacked = solve_centralized_QPnew(H, g, A, b)
    %SOLVEQP2 Solves a QP by 1st order necessary KKT condition
    neq = size(A,1);
    nx  = size(H,1);
     
    
    % sparse solution
    LEQS_As = sparse([H A';
                      A zeros(neq)]);
    LEQS_Bs = sparse([-g; b]);
    LEQS_xs = LEQS_As\LEQS_Bs;    


    if sum(isnan(LEQS_xs)) > 0 % regularization if no solution
      LEQS_As    = LEQS_As + 1*abs(min(eig(LEQS_As)))*eye(size(LEQS_As))+1e-3;

      LEQS_xs  = linsolve(LEQS_As,LEQS_Bs);
    end

    x_stacked    = LEQS_xs(1:nx);
    lam     = LEQS_xs((nx+1):end); 
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
