function [xsol, violation, logg] = admm_classic(problem, params)
% solve the distributed problem
    max_iter           = params.max_iter;
    tol                = params.tol;
    rho                = params.rou;
	Hessian            = problem.sens.HH;
    AA                 = problem.AA;
    b                  = problem.b;
    state              = problem.state;
%     for i = 1 : numel(X0)
%        X0{i} = X0{i}+randn(size(X0{i}))/10000;
%     end
    Xopt                  = problem.zz0;
    A                  = horzcat(AA{:});  % Ax - b = 0, centralized
    N_states           = get_number_of_state(state);

    %  initialize
    N_regions          = size(Xopt,1);
    Lambda             = problem.lam0;
    logg.X             = [];

    figure(2)
    hold on
    % ADMM - consensus form
    for j = 1:max_iter
        [bool, violation(j)] = check_terminal_condition(Xopt, A, tol);
                    xsol = Xopt;
            logg.iter = j;
        if bool
        end
        i = max_iter - j + 1;
        fprintf('iteration = %d\n', i);
        % #1 solve the decoupled NLPs 
        [Xopt, ~] = solve_local_NLPs(problem, Xopt, Lambda, rho);
        % dual variable update
        Lambda = Lambda + rho*build_primal_residual(A,Xopt);
        
        [bool, violation(j)] = check_terminal_condition(Xopt, A, tol);
        logg.X = [logg.X, vertcat(Xopt{:})];

%         if bool
%             xsol = Xopt;
%             return;
%         else
%             fprintf('norm of violation = %f\n', violation(i));
%             loglog(i,violation(i),'.','MarkerEdgeColor','b')
% %             xlim([0, log(max_iter)])
% %             ylim([-4, -1])
%             grid on
%             drawnow
%         end
%         
        
        % #2 terminate?
        
        
%                 
%         
%         step_length = norm( vertcat(X{:})-vertcat(Xopt{:}),1);
        [bool, primal_residual] = check_terminal_condition(Xopt, A, tol);
        violation(j) = primal_residual;
        primal_residual = norm(primal_residual,2);
        if bool
            xsol = Xopt;
            logg.iter = i;

            return;
        else
            fprintf('norm of violation = %f\n', violation(j));
%             plot(log10(j),log10(violation(i)),'.','MarkerEdgeColor','b')

              plot(j,log10(violation(j)),'.','MarkerEdgeColor','b')

            ylim([-6, -1])

              %             xlim([0, log10(max_iter)])
% grid on
            drawnow
        end
        A_n_1         = horzcat(AA{1:end-1});
%         dual_residual = norm( rho*A_n_1'*AA{end}*(Xopt{end}-X{end}),2);
%         if primal_residual>100*dual_residual
%             rho = rho*2;
%         elseif dual_residual>100*primal_residual
%             rho = rho/2;
%         end
        X=Xopt;
        
%         
        
        
        


        
%         
%         if norm(A*x_stacked,inf) > 0.9*norm(A*xOld,inf) && i > 1
% %            rho = rho*1.025;
%         end

    end
    xsol = Xopt;
        logg.iter = max_iter;

end

function [X, Lambda] = solve_local_NLPs(problem, X, Lambda, rho)
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
    A                  = horzcat(AA{:});  % Ax - b = 0, centralized
	llbx               = problem.llbx;
	uubx               = problem.uubx;
    N_regions          = size(X,1);
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
        Ai       = AA{i};
        xi       = X{i};
		Nx       =  numel(xi);
        local_residual = @(x)build_residual_in_local_step(i, x, X, A);
		objective      = @(x)build_objective(x, fi(x), grad_i(x), Lambda, Ai, rho, local_residual(x));
        opts.HessFcn   = @(x,kappa)(hess_i(x,0,0)+rho*Ai'*Ai);
            nonlcon = @(x)build_nonlcon(x, gi, hi, JJac_i);
		[xi, fval, flag, out, multiplier] = fmincon(objective, xi, [], [], [], [], lbx, ubx, nonlcon, opts);
        X{i}     = xi;
        % dual upgrate
%         Lambda = Lambda + rho*build_primal_residual(A,X);

        fprintf('converged!\n');    
    end
end

function [bool, violation] = check_terminal_condition(Y, A, tol)
% check whether the terminal condition fullfilled
    y         = cell2mat(Y);
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

function [fun, grad] = build_objective(xi, f, dfdx, lambda, Ai, rho, residual)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % the code assumes that Sigma is symmetric and positive definite!!!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fun = build_cost(xi, f, lambda, Ai) + rho*residual'*residual/2;
    if nargout > 1
        grad = build_grad(dfdx, lambda, Ai) + rho*(Ai'*(residual-Ai*xi) + Ai'*Ai*xi);
    end
end

function fun = build_cost(y, f, lambda, A)
    fun = f + lambda'*A*y;
end

function grad = build_grad(dfdx, lambda, A)
    grad = dfdx + A'*lambda;
end

function r = build_residual_in_local_step(i, x, X, A)
    % i - idx of current region
    X{i} = x;
    r = build_primal_residual(A, X);
end

function res = build_primal_residual(A, X)
    if iscell(X)
        X = vertcat(X{:});
    end
    res = A*X;
end

function [ineq, eq, jac_ineq, jac_eq] = build_nonlcon(x, g, h, dgdx)
    ineq = h(x);
    eq = g(x);
    if nargout > 2
        jac_ineq = [];
        jac_eq = dgdx(x)';
    end
end
