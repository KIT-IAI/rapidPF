clc
clear
close all
load matlab.mat
% % %
%     nlp = obj;
    % initial fmincon
%     opts                           = optimoptions('fmincon');
%     opts.Algorithm                 = 'interior-point';
% %     opts.Algorithm                 = 'sqp';
%     opts.CheckGradients            = false;
%     % gradient info - nlp.option
%     opts.SpecifyObjectiveGradient  = nlp.option.specify_obj_grad;
%     opts.SpecifyConstraintGradient = nlp.option.specify_con_jac;
%     % hessian of lagrangian func - nlp.option
%     if nlp.option.specify_lag_hess
%         % NLP with hess of lagrangian func
%         %% currently we have issue providing d2f of constraints
% %         if nlp.option.constrained
% %             opts.HessianApproximation = 'lbfgs';
% %         else
%                     opts.HessFcn              = @(y,kappa)nlp.hessian(y,kappa.eqnonlin,rho);
% %         end        
%     else
%         % NLP without hess of objective
%         opts.HessianApproximation = 'lbfgs';
%     end    
%     % constraints & hessian info
%     if ~nlp.option.constrained
%         % unconstrained NLP
%         nonlcon                       = [];
%     else
%         % constrained NLP
%         nonlcon = @(x)build_nonlcon(nlp,x);
%     end    
%     opts.StepTolerance = 1e-6;
%     % display options
% %     if nlp.option.iter_display
%         opts.Display   = 'iter';
% %     else 
% %         opts.Display   = 'none';
% %     end
% %         opts.Display   = 'final-detailed';
%     % initial and solve NLP by fmincon
%     cost_fun           = @(y)build_cost_fun(nlp, xi, y, lam, rho);
% %     opts.HonorBounds	= false;
% %     ((xi-nlp.lby)>=0) | ((xi-nlp.uby)<=0)
% %     [~,b] = nonlcon(xi);
% %     max(abs(b))
% Nx = numel(xi);
% A = vertcat(-speye(Nx),speye(Nx));
% b = vertcat(-nlp.lby,nlp.uby);
% 
%     [yi, ~, ~, flag, lambda,grad,hess]   = fmincon(cost_fun, xi, [], [], [], [], nlp.lby, nlp.uby, nonlcon, opts);
% %       [y2, ~, ~, flag, lambda,grad,hess]   = fmincon(cost_fun, xi, [], [], [], [], [], [], nonlcon, opts);
% %     opts.HessFcn              =[];
% %     opts.HessianApproximation = 'lbfgs';
% 
%     opts.Algorithm                 = 'sqp';
% 
%     [y2, ~, ~, flag, lambda,grad,hess]   = fmincon(cost_fun, xi, [], [], [], [], nlp.lby, nlp.uby, nonlcon, opts);
% %     norm(yi-y2,2)




%% casadi
    import casadi.*
    options.ipopt.tol         = 1.0e-8;
    options.ipopt.print_level = 5;
    %     options.ipopt.grad_f = fgrad;
    options.print_time        = 5;
    options.ipopt.max_iter    = 100;
obj = nlp
Nx = numel(xi);
Nkappa = numel(obj.local_funs.ceq(xi));
x_SX = SX.sym('state',Nx,1);
ffun = obj.objective(xi,x_SX,lam,rho);
gfun = obj.local_funs.ceq(x_SX);
hfun = @(y,kappa)nlp.hessian(y,kappa.eqnonlin,rho);
lbx  = obj.lby;
ubx  = obj.uby;
nlp = struct('x',x_SX,'f',ffun,'g',gfun);
S = nlpsol('solver','ipopt', nlp,options);
sol = S('x0', xi,'lbg', zeros(Nkappa,1),'ubg', zeros(Nkappa,1),...
        'lbx', lbx, 'ubx', ubx);
xopt  = full(sol.x);
kappa = full(sol.lam_g);
grad  = gradient(ffun,x_SX);
jac   = jacobian(gfun,x_SX);
hess  = hessian(ffun+kappa'*gfun,x_SX);

sens  = Function('sens',{x_SX},{grad,jac,hess});
  
% hess  = hessian()
% 
% [g,j,h] = sens(xopt);
%%
obj = nlp;

lbx  = obj.lby;
ubx  = obj.uby;

[nlp_casadi, Nx, Nkappa] = build_nlp_model_casadi(obj,xi,lam,rho);
yi = solve_nlp_casadi(nlp_casadi,xi,lam,rho,lbx,ubx,zeros(Nkappa,1),zeros(Nkappa,1));



function [nlp_model,Nkappa,sens_casadi] =  build_nlp_model_casadi(NLP,xi,lam,rho)
    import casadi.*
    Nx    = numel(xi);
    Nlam  = numel(lam);
    Nkappa = numel(NLP.local_funs.ceq(xi));
    xi_SX =  SX.sym('xi',Nx,1);
    yi_SX  = SX.sym('yi',Nx,1);
    lam_SX = SX.sym('lam',Nlam,1);
    rho_SX = SX.sym('rho',1,1);
    options.ipopt.tol         = 1.0e-8;
    options.ipopt.print_level = 5;
    %     options.ipopt.grad_f = fgrad;
    options.print_time        = 5;
    options.ipopt.max_iter    = 100;
%     Sigma         = SX.sym('SSig',[nx nx]);
    objective_fun = NLP.objective(xi_SX,yi_SX,lam_SX,rho_SX);
    con_fun       = NLP.local_funs.ceq(yi_SX);
    nlp           = struct('x',yi_SX,'f',objective_fun,'g',con_fun,'p',[rho_SX;lam_SX;xi_SX]);
    nlp_model     = nlpsol('solver','ipopt',nlp,options);
    %
    fi_casadi    = NLP.local_funs.fi(yi_SX);
    grad_casadi  = gradient(fi_casadi,yi_SX);
end

function yi = solve_nlp_casadi(nlp_model,xi,lam,rho,lby,uby,lbg,ubg)
    sol = nlp_model('x0',   xi,...
                    'p',    [rho;lam;xi],...
                    'lbx',  lby,...
                    'ubx',  uby,...
                    'lbg',  lbg,...
                    'ubg',  ubg);
    yi = sol.x;
end


function [fun, grad, hessian] = build_cost_fun(obj,x,y,lambda,rho)
    % objective fun of local NLP
    fun = obj.objective(x,y,lambda,rho);
    if nargout > 1
        % gradient of local NLP
        grad = obj.gradient(x,y,lambda,rho);
        if nargout > 2
            % fmincon - hessian of lagrangian function of local NLP
            hessian = obj.hessian(y,0,0);
        end
    end
end

function [ineq, eq, jac_ineq, jac_eq] = build_nonlcon(nlp,x)
    % build nonlinear constraints function
    switch nlp.option.con_type
        case 'eq'
                ineq = [];
                eq   = nlp.ceq(x)';
                if nargout > 2
                    jac_ineq = [];
                    jac_eq   = nlp.jac_ceq(x)';
                end
        case 'ineq'
                ineq = nlp.cineq(x);
                eq   = [];

                if nargout > 2
                    jac_ineq = nlp.jac_cineq(x)';
                    jac_eq   = [];
                end
        case 'both'
                ineq = nlp.cineq(x);
                eq   = nlp.ceq(x);  
                if nargout > 2
                    jac_ineq = nlp.jac_cineq(x)';
                    jac_eq   = nlp.jac_ceq(x)';
                end
    end
end


