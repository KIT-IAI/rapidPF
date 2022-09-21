classdef localNLP
    %LOCALNLP initialize and solve local Non-Linear Problem and compute sensitivities for global step
    %   Detailed explanation goes here    
    properties
        local_funs  originalFuns % cost, gradient of cost and hessian of cost
        Nxi
        Nlami
        Nkappai
        lby                   % lower boundary of local variable yi
        uby                   % upper boundary of local variable yi
        idx_ang               % entries of angle varibles
        kappa                 % langrangian multiplier of local constraints
        objective             % objective function of local NLP
        gradient              % gradient vector-function of local NLP
        hessian               % hessian of lagrangian function of local NLP
        ceq                   % equality constraints
        jac_ceq               % jacobian matrix of equality constraints
        cineq                 % inequality constraints
        jac_cineq             % jacobian matrix of inequality constraints
        casadi_model          % model for casadi
        option    NLPoption   % option for local NLPs 
    end
    
    methods
       
        %Constructor
        function obj = localNLP(local_funs,option,lby,uby)
        %% iniitialize local NLP by setting objective/gradient/hesian of local NLP
            if nargin >0
                if nargin > 2
                    obj.option = option;
                    obj.Nxi   = numel(lby);
                    obj.Nlami = size(local_funs.Ai,1);
                    % default - scaling matrix = Ai'*Ai
                    Sigma     = speye(obj.Nxi);   
                    
                    %% preprocessing - constraint
                    constraint_decision  = num2str([isempty(local_funs.ceq) isempty(local_funs.cineq)]);
                    if strcmp(obj.option.solver,'casadi')
                        %jacobian is not necessary when using casadi as solver
                        specify_eq_jac   = false;
                        specify_ineq_jac = false;
                        
                    else
                        specify_eq_jac   = ~isempty(local_funs.jac_ceq);
                        specify_ineq_jac = ~isempty(local_funs.jac_cineq);
                    end
                    % setting according to constraint type
                    switch constraint_decision
                        case '1  1'
                            % unconstrained
                            obj.option.con_type          = 'unconstrained';
                            obj.option.constrained       = false;
                        case '0  1'
                            % equality constrained
                            obj.option.con_type          = 'eq';
                            obj.option.constrained       = true;
                            obj.option.specify_con_jac   = specify_eq_jac;
                            obj.ceq                  = @(y)local_funs.ceq(y);
                            if specify_eq_jac
                                % jacobian of equality constraints
                                obj.jac_ceq   = @(y)local_funs.jac_ceq(y);
                            end
                        case '1  0'
                            % inequality constrained
                            obj.option.con_type          = 'ineq';
                            obj.option.constrained       = true;
                            obj.option.specify_con_jac   = specify_ineq_jac;
                            obj.cineq                = @(y)local_funs.ceq(y);
                            if specify_ineq_jac
                                % jacobian of equality constraints
                                obj.jac_cineq = @(y)local_funs.jac_cineq(y);
                            end                            
                        otherwise
                            % both inequality and equality constrained
                            obj.option.con_type          = 'both';
                            obj.option.constrained       = true;
                            obj.option.specify_con_jac   = specify_ineq_jac && specify_eq_jac;
                            obj.ceq                  = @(y)local_funs.ceq(y);
                            obj.cineq                = @(y)local_funs.cineq(y);
                            if specify_eq_jac
                                % jacobian of equality constraints
                                obj.jac_ceq   = @(y)local_funs.jac_ceq(y);
                            end
                            if specify_ineq_jac
                                % jacobian of equality constraints
                                obj.jac_cineq = @(y)local_funs.jac_cineq(y);
                            end
                    end
                        
                    %% preprocessing - cost / gradient / Hessian 
                    obj.local_funs  = local_funs;
                    switch obj.option.solver
                        case {'casadi'}
                            % casadi as local solver -
                            % gradient and hessian can be computed by casadi 
                            obj.option.sens = 'casadi';
                            obj.option.specify_obj_grad = false;
                            obj.option.specify_lag_hess = false;
                            obj.option.specify_con_jac  = false;
                            obj.objective   = @(x,y,lambda,rho) local_funs.fi(y) + lambda'*local_funs.Ai*y + 0.5*rho*(y - x)'*Sigma*(y - x);
                            [obj.casadi_model,obj.Nkappai] = obj.build_local_model_casadi;
                        case {'lsqnonlin'}
                        % lsqnonlin for solving nonlinear equation    
                            if ~isempty(local_funs.ri) && ~isempty(local_funs.dri)
                                % residual function of local NLP
                                obj.objective   = @(x,y,lambda,rho)[local_funs.ri(y);sqrt(0.5*rho)*Sigma*(y - x)];
                                % gradient of residual function
                                obj.gradient    = @(x,y,lambda,rho)[local_funs.dri(y);sqrt(0.5*rho)*Sigma];
                                % hessian of local NLP
                                obj.hessian     = @(y,rho) local_funs.hi(y,0,0) + rho * Sigma;
                            else
                                error('Residual function is necessary for lsqnonlin solver')
                            end
                        case {'MA57','mldivide','cg_steihaug'}
                            
                        otherwise
                            % standard nlp problem
                            % option setting for local NLP - check empty
                            obj.option.specify_obj_grad  = ~isempty(local_funs.gi);
                            obj.option.specify_lag_hess  = ~isempty(local_funs.hi);
                            % objective, gradient of objective and hess of lagrangian
                            % objective function of NLP
                            obj.objective = @(x,y,lambda,rho) local_funs.fi(y) + lambda'*local_funs.Ai*y + 0.5*rho*(y - x)'*Sigma*(y - x);
                            if obj.option.specify_obj_grad 
                                % gradient vector-function of objective function
                                obj.gradient    = @(x,y,lambda,rho) local_funs.gi(y) + local_funs.Ai'*lambda + rho * Sigma *(y - x);
                                if obj.option.specify_lag_hess
                                    obj.hessian = @(y,kappa,rho) local_funs.hi(y,kappa) + rho * Sigma;
                                end
                            end
                    end
                end
                % check angle variable -> dont use upper/lower constraints
                if nargin > 3
                    obj.idx_ang          =  sparse((lby==-pi)&(uby==pi));
                    obj.lby              =  lby;
                    obj.uby              =  uby;
                    obj.lby(obj.idx_ang) = -inf;
                    obj.uby(obj.idx_ang) =  inf;
                end
            end
        end
       
        %Methods2 - solve local NLP problem
        function [yi,senstivities] = solve_local_NLP(obj,xi,lam,rho)
        %% solve_local_NLP solve local Non-Linear Problem by applying specify solver
        %    solvers including  1. fmincon   (default)
        %                       2. fminunc   (unconstrained only)
        %                       3. lsqnonlin (unconstrained only)
        %             fval = [];
            % 3 solvers avaliable for unconstrained NLP  
            switch obj.option.solver 
                % switch between different solver
                case {'fmincon'}
                    yi  = solve_nlp_fmincon(obj,xi,lam,rho);
                case {'fminunc'}
                    yi  = solve_nlp_fminunc(obj,xi,lam,rho);
                case {'lsqnonlin'}
                    yi  = solve_nlp_lsqnonlin(obj,xi,lam,rho);
                case {'casadi'}
                    yi  = solve_nlp_casadi(obj,xi,lam,rho);
                case {'MA57'}
                    [grad, ~, hess] =   obj.local_funs.sens(xi);
                    yi  = xi + ma57_solver(hess+2*rho*speye(obj.Nxi), -grad);
                case {'mldivide'}
                    [grad, ~, hess] =   obj.local_funs.sens(xi);
                    yi  = xi + (hess+2*rho*speye(obj.Nxi))\ -grad;
                case {'cg_steihaug'}
                    [grad, JJp] =   obj.local_funs.sens(xi);
                    yi  = xi + cg_steihaug(@(p)(JJp(p)+rho*speye(obj.Nxi)*p),-grad,0.1,3);
                otherwise
                    fprintf('/nsolver unavaliable, using fmincon instead/n')
                    yi  = solve_nlp_fmincon(obj,xi,lam,rho);
            end
            % dont have lambda for unconstrained problem


            %   compute sensitivities of local Non-Linear Problem
% 
%             grad = obj.local_funs.gi(xi);
%             Hess = obj.local_funs.hi(xi,0)+2*rho*speye(obj.Nxi);
%             pk   = ma57_solver(Hess,-grad);
%             pk   = - (Hess+2*rho*eye(obj.Nxi))\grad;
%             error = norm(yi-xi-pk,2)
%             yi = xi+pk;
            if any(obj.idx_ang) 
                yi          = wrap_ang_variable(yi,obj.idx_ang);
            end
            senstivities    = localSensitivities(obj, yi);
%             if ~isempty(fval)
%                 senstivities.fval = fval;
%             end
        end
        
        %Methods3 - build nlp model for casadi
        function [casadi_model,Nkappa] =  build_local_model_casadi(obj)
        %% inilialize casadi for local NLP step
            import casadi.*
            xi_SX       = SX.sym('xi',obj.Nxi,1);
            yi_SX       = SX.sym('yi',obj.Nxi,1);
            lam_SX      = SX.sym('lam',obj.Nlami,1);
            rho_SX      = SX.sym('rho',1,1);
            % equality constraint & jacobian
            if ~isempty(obj.local_funs.ceq)
                Nkappa.eq             = numel(obj.local_funs.ceq(zeros(obj.Nxi,1)));
                ceq_casadi            = obj.local_funs.ceq(yi_SX);
            else
                Nkappa.eq             = 0;
                ceq_casadi            = [];
            end
            % inequality constraint & jacobian
            if ~isempty(obj.local_funs.cineq)
                Nkappa.ineq           = numel(obj.local_funs.cineq(zeros(obj.Nxi,1)));
                cineq_casadi          = obj.local_funs.cineq(yi_SX);
            else
                Nkappa.ineq           = 0;
                cineq_casadi          = [];
            end
            casadi_model.ubg          = zeros(Nkappa.eq+Nkappa.ineq,1);
            casadi_model.lbg          = vertcat(-inf*ones(Nkappa.ineq,1),zeros(Nkappa.eq,1));
            kappa_SX                  = SX.sym('kappa',Nkappa.eq+Nkappa.ineq,1);
            % equality & inequality constraints
            constraint_casadi         = vertcat(cineq_casadi,ceq_casadi);
            % casadi setting
            options.ipopt.tol         = obj.option.tol;
            if obj.option.iter_display
                display_val = 5;
            else
                display_val = 0;
            end
            options.ipopt.print_level = display_val;
            options.print_time        = display_val;
            options.ipopt.max_iter    = 200;
            options.ipopt.constr_viol_tol = obj.option.tol;
            % obj function
            objective_fun             = obj.objective(xi_SX,yi_SX,lam_SX,rho_SX);
            % NLP struct
            nlp                       = struct('x',yi_SX,'f',objective_fun,'g',constraint_casadi,'p',[rho_SX;lam_SX;xi_SX]);
            % casadi nlp model
            casadi_model.nlp          = nlpsol('solver','ipopt',nlp,options);
            % sensitivities - cost & gradient
%             fi_casadi                 = obj.local_funs.fi(yi_SX);
%             grad_casadi               = gradient(fi_casadi,yi_SX);
%             % sensitivities - jacobian
%             jac_casadi                = jacobian(constraint_casadi,yi_SX);    
%             % sensitivities - hessian of lagrangian function
%             if isempty(constraint_casadi)
%                 hess_casadi               = hessian(fi_casadi,yi_SX);
%                 casadi_model.sens         = Function('sens',{yi_SX},{grad_casadi,jac_casadi,hess_casadi});
%             else
%                 hess_casadi               = hessian(fi_casadi+kappa_SX'*constraint_casadi,yi_SX);
%                 casadi_model.sens         = Function('sens',{yi_SX,kappa_SX},{grad_casadi,jac_casadi,hess_casadi});
%             end
        end
    end
end

function [yi,kappa,fval] = solve_nlp_casadi(nlp,xi,lam,rho)
%% solve local nlp by casadi
    sol   = nlp.casadi_model.nlp('x0',   xi,...
                                 'p',    [rho;lam;xi],...
                                 'lbx',  nlp.lby,...
                                 'ubx',  nlp.uby,...
                                 'lbg',  nlp.casadi_model.lbg,...
                                 'ubg',  nlp.casadi_model.ubg);
    yi    = full(sol.x);
    fval  = full(sol.f);
    kappa = full(sol.lam_g);
end

function [yi, lambda,grad,hess] = solve_nlp_fmincon(nlp,xi,lam,rho)
%% solve local nlp by fmincon
    % initial fmincon
    opts                           = optimoptions('fmincon');
    opts.Algorithm                 = 'interior-point';
%     opts.Algorithm                 = 'sqp';
    opts.CheckGradients            = false;
    % gradient info - nlp.option
    opts.SpecifyObjectiveGradient  = nlp.option.specify_obj_grad;
    opts.SpecifyConstraintGradient = nlp.option.specify_con_jac;
    % hessian of lagrangian func - nlp.option
    if nlp.option.specify_lag_hess
        % NLP with hess of lagrangian func
        %% currently we have issue providing d2f of constraints
        if nlp.option.constrained
            opts.HessianApproximation = 'lbfgs';
        else
                    opts.HessFcn              = @(y,kappa)nlp.hessian(y,kappa.eqnonlin,rho);
        end        
    else
        % NLP without hess of objective
        opts.HessianApproximation = 'lbfgs';
    end    
    % constraints & hessian info
    if ~nlp.option.constrained
        % unconstrained NLP
        nonlcon                       = [];
    else
        % constrained NLP
        nonlcon = @(x)build_nonlcon(nlp,x);
    end    
%     opts.StepTolerance = 1e-6;
    % display options
    if nlp.option.iter_display
        opts.Display   = 'iter';
    else 
        opts.Display   = 'none';
    end
    cost_fun            = @(y)build_cost_fun(nlp, xi, y, lam, rho);
     [yi, ~, ~, flag, lambda,grad,hess]   = fmincon(cost_fun, xi, [], [], [], [], nlp.lby, nlp.uby, nonlcon, opts);
end

function yi = solve_nlp_fminunc(nlp,xi,lam,rho)
    %% solve local nlp by fminunc
    opts                          = optimoptions('fminunc');
    opts.Algorithm                = 'trust-region';
    opts.CheckGradients           = false;
    opts.SpecifyObjectiveGradient = nlp.option.specify_obj_grad;
%     opts.SubproblemAlgorithm      = 'factorization';
    if nlp.option.specify_lag_hess
        opts.HessianFcn           =  [];%'objective';
    end
        
    if nlp.option.iter_display
        opts.Display              = 'iter';
    else 
        opts.Display              = 'none';
    end
    % initial and solve NLP by fmincon
    cost_fun            = @(y)build_cost_fun(nlp, xi, y, lam, rho);
    [yi, ~, ~, ~, ~, ~] = fminunc(cost_fun, xi, opts);
end

function yi = solve_nlp_lsqnonlin(nlp,xi,lam,rho)
    %% solve local nlp by lsqnonlin
    opts                           = optimoptions('lsqnonlin');
    opts.Algorithm                 = 'levenberg-marquardt';
    opts.ScaleProblem              = 'jacobian';
    opts.CheckGradients            = false;
    opts.SpecifyObjectiveGradient  = true;
    if nlp.option.iter_display
        opts.Display               = 'iter';
    else 
        opts.Display               = 'none';
    end
    % initial cost function and SpecifyObjectiveGradient  opts.HessFcn
    residual     = @(y)build_cost_fun(nlp, xi, y, lam, rho);
    yi           = lsqnonlin(residual, xi, [], [], opts);
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


