clc;
clear
close all
load matlab.mat
%%
    options.ipopt.tol         = 1.0e-8;
    options.ipopt.print_level = 5;
    options.print_time        = 5;
    options.ipopt.max_iter    = 100;
    
    sensitivities
%% start
    mu           = obj.logg.mu(k);
    rho          = obj.logg.rho(k);
    y0           = obj.logg.Y(:,k);
    import casadi.*
    dx_SX = SX.sym('dx',obj.Nx,1);
    s_SX  = SX.sym('dx',obj.Nlam,1);
    X_SX  = vertcat(dx_SX,s_SX);
    
    Hk = blkdiag(sensitivities(:).Hess,speye(obj.Nlam)*mu);
    C            = blkdiag(sensitivities(:).jacobian);  % jacobian of constraint
    Ncon         = size(C,1);
    
    gk           = vertcat(sensitivities(:).grad,lam);
    
    Aeq          = [obj.A, -speye(obj.Nlam);
                    C,sparse(Ncon,obj.Nlam)];
    beq          = sparse(1:obj.Nlam,1,-obj.A*y0,obj.Nlam+Ncon,1);
    objective_fun =   X_SX'*Hk*X_SX/2 + gk'*X_SX;
    con_fun       =   Aeq*X_SX - beq;
    lbx          = vertcat(sensitivities(:).lbdy,-inf*ones(obj.Nlam,1));
    ubx          = vertcat(sensitivities(:).ubdy,inf*ones(obj.Nlam,1));    

    nlp           = struct('x',X_SX,'f',objective_fun,'g',con_fun);
    S             = nlpsol('solver','ipopt',nlp,options);
    X0 = vertcat(y0,zeros(obj.Nlam,1));
    sol = S('x0',   X0,...
                               'lbx',  lbx,...
                               'ubx',  ubx,...
                               'lbg',  zeros((Ncon+obj.Nlam),1),...
                               'ubg',  zeros((Ncon+obj.Nlam),1));
xopt = sol.x;
       

%%



    opts                           = optimoptions('fmincon');
            opts.Algorithm                 = 'sqp';
    opts.CheckGradients            = false;
%     gradient info - nlp.option
    opts.SpecifyObjectiveGradient  = true;
        opts.Display   = 'none';
    
                % extract data from main loop
            option       = obj.option.qp;
            [Nlam,Nx]    = size(obj.A);
            y0 = obj.logg.Y(:,k);
%             extract parameter from logg
            k            = obj.logg.iter;
            mu           = obj.logg.mu(k);
            rho          = obj.logg.rho(k);
            Hk           = blkdiag(sensitivities(:).Hess,speye(obj.Nlam)*mu);
            gk           = vertcat(sensitivities(:).grad,lam);
            C            = blkdiag(sensitivities(:).jacobian);  % jacobian of constraint
            Ncon         = size(C,1);
            Aeq          = [obj.A, -speye(obj.Nlam);
                            C, sparse(Ncon,obj.Nlam)];
            beq          = sparse(1:obj.Nlam,1,-obj.A*y0,obj.Nlam+Ncon,1);
%             HQP          = blkdiag(Hk
            lbx          = vertcat(sensitivities(:).lbdy,-inf*ones(obj.Nlam,1));
            ubx          = vertcat(sensitivities(:).ubdy,inf*ones(obj.Nlam,1));
            x0           = vertcat(y0,zeros(obj.Nlam,1));
            opts.HessFcn              = @(y,kappa)Hk;
            fun = @(x) x'*Hk*x/2 + gk'*x;
            grad = @(x) Hk*x + gk;
            cost_fun           = @(x)build_cost_fun(fun(x), grad(x));
            [xopt2,~,ex,~,lambda,~,~] = fmincon(cost_fun,x0,[],[],Aeq,beq,lbx,ubx,[],opts);

            
            
function [fun_out, grad_out] = build_cost_fun(fun,grad)
    % objective fun of local NLP
    fun_out = fun;
    if nargout > 1
        % gradient of local NLP
        grad_out = grad;
    end
end