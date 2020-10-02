function [xsol, violation, logg] = solve_distributed_problem_with_ADMM(problem, params, X0)
% solve the distributed problem
    max_iter           = params.max_iter;
    tol                = params.tol;
    rho                = params.rou;
	Hessian            = problem.sens.HH;
    AA                 = problem.AA;
    b                  = problem.b;
    state              = problem.state;
    X                  = X0;
    A                  = horzcat(AA{:});  % Ax - b = 0, centralized
    N_states           = get_number_of_state(state);

    %  initialize
    lam0               = problem.lam0;
    N_regions          = size(X,1);
    Lambda             = {};
    HQP                = []; % 
    logg.X             = [];
    % regularization only for components not involved in consensus and
    % project them back on x_k
    gam   = 1e-10;
    L     = diag(double(~sum(abs(A))));    
    for i = 1:N_regions
        Lambda{i} = lam0;
       % build H and A for ctr. QP    
        HQP = blkdiag(HQP, rho*AA{i}'*AA{i});
    end
    HQP   = HQP + gam*L'*L;
    figure(1)
    hold on
    % ADMM - consensus form
    for i = 1:max_iter
        fprintf('iteration = %d\n', i);
        xOld   = cell2mat(X);
        % #1 solve the decoupled NLPs 
        [Y, ~] = solve_local_NLPs(problem, X, Lambda, rho);
        % #2 terminate?
        [bool, violation(i)] = check_terminal_condition(Y, A, tol);
        logg.X = [logg.X, vertcat(Y{:})];

        if bool
            xsol = Y;
            return;
            logg.iter = i;
        else
            fprintf('norm of violation = %f\n', violation(i));
            loglog(i,violation(i),'.','MarkerEdgeColor','b')
%             xlim([0, log(max_iter)])
%             ylim([-4, -1])
            grid on
            drawnow
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
%         X = Y';
        
%         [bool, violation(i)] = check_terminal_condition(X, A, tol);

        % #4 lambda update
%         for j = 1:N_regions
%             Lambda{j} = Lambda{j} + rho*AA{j}*(Y{j}-X{j});
%         end        
        % #5 update rule according to Guo 17 from remote point
        % currently rho update is not actived
        if norm(A*x_stacked,inf) > 0.9*norm(A*xOld,inf) && i > 1
%            rho = rho*1.025;
        end
    end
    xsol = X;
    logg.iter = max_iter;
    logg.X(:,max_iter) = vertcat(X{:});

end

function [Y, Lambda] = solve_local_NLPs(problem, X, Lambda, rho)
% solve decoupled NLPs for all regions
    opts = optimoptions('fmincon');
    opts.Algorithm = 'interior-point';
    opts.CheckGradients = false;
    opts.SpecifyConstraintGradient = true;
    opts.SpecifyObjectiveGradient = true;
    opts.Display = 'iter';
    costs              = problem.locFuns.ffi;
    equalities         = problem.locFuns.ggi;
    inequalities       = problem.locFuns.hhi;
	gradient           = problem.sens.gg;
	jacobian           = problem.sens.JJac;
	hessian            = problem.sens.HH;
    AA                 = problem.AA;
	llbx               = problem.llbx;
	uubx               = problem.uubx;
	
    N_regions          = size(X,1);
    % options = optimoptions(@fminunc,'Display','iter','Algorithm','quasi-newton', 'MaxFunctionEvaluations', 10000);
    % options = optimoptions(@fmincon,'Algorithm','interior-point','Display','iter','MaxFunctionEvaluations', 10000);
    % options = optimoptions(@fmincon,'Algorithm','interior-point','Display','off','MaxFunctionEvaluations', 10000);
    % solve decoupled NLPs
    for i = 1 : N_regions
        fprintf('Region N0.%d ...', i);
        fi       = costs{i};    
        gi       = equalities{i};
		hi       = inequalities{i};
		JJac_i   = jacobian{i};
		grad_i   = gradient{i};
		hess_i   = hessian{i};
		ubx      = uubx{i};
		lbx      = llbx{i};
        % if isempty(inequalities{1}(0))
        %     % fmincon fail when c(x) = []
        %     hi   = @(x)(zeros);
        % else
        %     hi   = problem.locFuns.hhi{1};
        % end
        lambda_i    = Lambda{i};
        Ai       = AA{i};
        xi       = X{i};
		Nx  =  numel(xi);
		Sigma    = eye(Nx,Nx);
		objective    = @(x)build_objective(x, fi(x), grad_i(x), [], lambda_i, Ai, rho, xi, Sigma);
        opts.HessFcn = @(x,kappa)build_hessian(hess_i(x,0,0), zeros(Nx,Nx), rho, Sigma);
		nonlcon = @(x)build_nonlcon(x, gi, hi, JJac_i);
		[yi, fval, flag, out, multiplier] = fmincon(objective, xi, [], [], [], [], lbx, ubx, nonlcon, opts);

        % J        = @(yi)(fi(yi) + lam_i'*Ai*yi + penalty_term(yi,xi,Ai,rho));
        % solve a decoupled NLP of the current region
        % yi       = fmincon(J,xi,[],[],[],[],[],[], @nonlinear_constraints,options);
		
        Y{i}     = yi;
        % dual upgrate
        Lambda{i}= lambda_i + rho*Ai*(yi-xi);
        fprintf('converged!\n');    
    end
end

function [bool, violation] = check_terminal_condition(Y, A, tol)
% check whether the terminal condition fullfilled
    y         = cell2mat(Y');
    violation = norm(A*y,1);
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

function N_states = get_number_of_state(X)
% get the numbers of states in each region
    N_regions = size(X,1);
    N_states = [];
    for i = 1:N_regions
        N_states(i) = size(X{i},1);
    end
end

function [fun, grad, Hessian] = build_objective(x, f, dfdx, H, lambda, A, rho, z, Sigma)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % the code assumes that Sigma is symmetric and positive definite!!!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fun = build_cost(x, f, lambda, A, rho, z, Sigma);
    if nargout > 1
        grad = double(build_grad(x, dfdx, lambda, A, rho, z, Sigma));
        if nargout > 2
            % only called by fminunc
            Nx      = numel(x);
            Hessian = build_hessian(H,zeros(Nx,Nx), rho, Sigma);
        end
    end
end

function fun = build_cost(y, f, lambda, A, rho, x, Sigma)
    fun = f + lambda'*A*y + 0.5*rho*(y - x)'*Sigma*(y - x);
end

function grad = build_grad(y, dfdx, lambda, A, rho, x, Sigma)
    grad = dfdx + A'*lambda + rho*Sigma*(y - x);
end

function hm  = build_hessian(hessian_f, kappa_hessian_g, rho, Sigma, scale)
    if nargin > 4
        % worhp scale hessian_f
        hessian_f = hessian_f .* scale;
    end
    hm   = hessian_f + rho * Sigma + kappa_hessian_g;
end

function [ineq, eq, jac_ineq, jac_eq] = build_nonlcon(x, g, h, dgdx)
    ineq = h(x);
    eq = g(x);
    if nargout > 2
        jac_ineq = [];
        jac_eq = dgdx(x)';
    end
end

