classdef globalQP
    %GLOBALQP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        HQP       % sensitivities - hessian of original local cost
        gQP       % sensitivities - gradient of original local cost
        AQP       % constraints   - consensus, equality, inequality
        bQP       %
        KQP       % rest diag matrix - zeros when not defined
        Y0        % initial value
        ubdy      % upper boundary of du
        lbdy      % lower boundary of du
        ubg       % upper boundary of constraints
        lbg       % lower boundary of constraints
        option    QPoption
        sens
    end
    
    methods
        function obj = globalQP(problem, sensitivities, consensus_residual,lam)
            %% GLOBALQP Construct an Quadratic problem at current iteration
            %   Detailed explanation goes here
            
            % extract data from main loop
            logg         = problem.logg;
            obj.option   = problem.option.qp;
            % extract parameter from logg
            k            = logg.iter;
            mu           = logg.mu(k);
            rho          = logg.rho(k);
%             obj.sens     = sensitivities;
            Hk           = blkdiag(sensitivities(:).Hess);
%             sens         = sensitivities;
            gk           = vertcat(sensitivities(:).grad);
            % check regularization setting
%             if obj.option.regularization_hess
%                 gamma    = max(logg.primal_feasibility(k),logg.dual_feasibility(k)/rho);%/1.1^double(k);%/1.1^double(k)
%                 if gamma > 1e-4
%                     Hk = Hk+gamma*speye(problem.Nx);
%                 end
%             end
            if strcmp(obj.option.solver,'casadi')
                % solve global problem by casadi
                y0       = problem.logg.Y(:,k);
                obj.Y0   = vertcat(y0,zeros(problem.Nlam,1));
                obj.HQP  = blkdiag(Hk,speye(problem.Nlam)*mu);
                obj.gQP  = vertcat(gk,lam);
                C        = blkdiag(sensitivities(:).jacobian);  % jacobian of constraint
                Nactive_cons = size(C,1);                       % number of active constraints
                obj.AQP  = [problem.A, -speye(problem.Nlam);
                            C,          sparse(Nactive_cons,problem.Nlam)];
                obj.bQP  = sparse(1:problem.Nlam,1,-problem.A*y0,problem.Nlam+Nactive_cons,1);
                % bounds - ratio: limit on s (slack)
                if logg.local_steplength(k)<=1e-5
                    ratio    = logg.local_steplength(k)/logg.mu(k);
                else
                    ratio    = logg.local_steplength(k)/logg.mu(k);
                end
                obj.lbdy = vertcat(sensitivities(:).lbdy,-ratio*ones(problem.Nlam,1));
                obj.ubdy = vertcat(sensitivities(:).ubdy,ratio*ones(problem.Nlam,1));
                obj.ubg  = zeros((Nactive_cons+problem.Nlam),1);
                obj.lbg  = zeros((Nactive_cons+problem.Nlam),1);
            elseif ~obj.option.constrained
                % unconstrained
%                 lam      = zeros(size(lam));
                obj.HQP  = Hk;
                obj.gQP  = gk;%+problem.A'*lam;
                obj.KQP  = -speye(problem.Nlam)/mu;
                obj.AQP  = problem.A;
                obj.bQP  = consensus_residual;
                % step limit on yi - global
                if ~isempty(vertcat(sensitivities.lbdy)) && ~isempty(vertcat(sensitivities.ubdy))
                    obj.lbdy = vertcat(sensitivities.lbdy);
                    obj.ubdy = vertcat(sensitivities.ubdy);
                end    
            else
                % constrained
                C        = blkdiag(sensitivities(:).jacobian);  % jacobian of constraint
                Nactive_cons     = size(C,1);                      % number of constraints
                obj.HQP  = [Hk,         problem.A';
                            problem.A, -speye(problem.Nlam)/mu];
                obj.gQP  = gk+problem.A'*lam;
                obj.KQP  = sparse(Nactive_cons,Nactive_cons);
                obj.AQP  = horzcat(C, sparse(Nactive_cons,problem.Nlam));
                obj.bQP  = vertcat(consensus_residual, sparse(Nactive_cons,1));
                % step limit on yi - global
                if ~isempty(vertcat(sensitivities.lbdy)) && ~isempty(vertcat(sensitivities.ubdy))
                    obj.lbdy = vertcat(sensitivities.lbdy);
                    obj.ubdy = vertcat(sensitivities.ubdy);
                end
            end
            

        end
        
        function [dy,dlam] = solve_global_qp(obj,Nlam,Nx,lam)
            %% Solve equvialent linear system - A x = b 
            if strcmp(obj.option.solver, 'casadi')
                % solve quadratic problem
                [dy, dlam] = obj.solve_global_qp_casadi(Nx,Nlam,lam);
            else
                % solve equivialent linear system

                % solve QP
                switch obj.option.solver
                    case 'lu'
                        LEQS_As   =  [obj.HQP, obj.AQP'; obj.AQP, obj.KQP];
                        LEQS_Bs   = -[obj.gQP;obj.bQP];
                        [L, U, P] = lu(LEQS_As);
                        LEQS_xs   = U\(L\(P*LEQS_Bs));
                        dy        = LEQS_xs(1:Nx);
                        dlam      = LEQS_xs((Nx+1):(Nx+Nlam));
                    case 'mldivide'
                        dy   = - (obj.HQP + obj.AQP'*100*obj.AQP)...
                               \(obj.AQP'*100*obj.bQP + obj.gQP);
                        dlam = sparse(Nlam,1);
                    case 'MA57'
%                         LEQS_Bs   = -[obj.gQP;obj.bQP];
%                         LEQS_xs   = cg_steihaug(obj,LEQS_Bs);
%                         LEQS_xs = LEQS_As\LEQS_Bs;
%                         [L, D, P] = ldl(LEQS_As);
%                         LEQS_xs   = P*(L'\(D\(L\(P'*LEQS_Bs))));
                        LEQS_As   =  [obj.HQP, obj.AQP'; obj.AQP, obj.KQP];
                        LEQS_Bs   = -[obj.gQP;obj.bQP];
                        LEQS_xs   = ma57_solver(LEQS_As, LEQS_Bs);
                        dy        = LEQS_xs(1:Nx);
                        dlam      = LEQS_xs((Nx+1):(Nx+Nlam));
                    case 'cg_steihaug'
                        delta    = (obj.AQP'*obj.KQP*obj.bQP - obj.gQP)'*(obj.AQP'*obj.KQP*obj.bQP - obj.gQP);
%                         dy   = cg_steihaug((obj.HQP + obj.AQP'*100*obj.AQP),-(obj.AQP'*100*obj.bQP + obj.gQP),1e-16,10000);
                        dy   = cgs((obj.HQP + obj.AQP'*100*obj.AQP),-(obj.AQP'*100*obj.bQP + obj.gQP),1e-8,10000);
%                         dy = pcg((obj.HQP + obj.AQP'*100*obj.AQP),-(obj.AQP'*100*obj.bQP + obj.gQP), 1e-6,100000);
%                         norm(dy1-dy,2)
%                         opt.SYM = true;
%                         opt.POSDEF =true;
%                         dy        = linsolve(full(obj.HQP + obj.AQP'*100*obj.AQP), -full(obj.AQP'*100*obj.bQP + obj.gQP),opt);
                        dlam = sparse(Nlam,1);
                    otherwise % default - 'lsqminnorm'
                        LEQS_As   =  [obj.HQP, obj.AQP'; obj.AQP, obj.KQP];
                        LEQS_Bs   = -[obj.gQP;obj.bQP];                    
                        N_xs    = numel(LEQS_Bs);
                        lb      = -ones(N_xs,1)*inf;
                        ub      = ones(N_xs,1)*inf;    
                        lb(1:Nx) = obj.lbdy;
                        ub(1:Nx) = obj.ubdy;
                        LEQS_xs = lsqlin(LEQS_As,LEQS_Bs,[],[],[],[],lb,ub);%                 case 'pinv'
                        dy        = LEQS_xs(1:Nx);
                        dlam      = LEQS_xs((Nx+1):(Nx+Nlam));
 %                     LEQS_xs = lsqlin(LEQS_As,LEQS_Bs,[],[],[],[],[],[]);
    %                     dxs = norm(LEQS_xs-LEQS_2,inf)
    %                     LEQS_xs = pinv(LEQS_As,LEQS_Bs);
    %                 case 'linsolve'
    %                     LEQS_xs = linsolve(LEQS_As,LEQS_Bs);
                        LEQS_As   =  [obj.HQP, obj.AQP'; obj.AQP, obj.KQP];
                        LEQS_Bs   = -[obj.gQP;obj.bQP];                    
                        LEQS_xs = lsqminnorm(LEQS_As,LEQS_Bs);
                end
            end
        end
        
        function [dy,dlam] = solve_global_qp_casadi(obj,Nx,Nlam,lam)
            %% Solve global QP problem by casadi
            import casadi.*
            % casadi setting
            options.ipopt.tol      = obj.option.tol;
            if obj.option.iter_display
                val = 5;
            else
                val = 0;
            end
            options.ipopt.print_level = val;
            options.print_time        = val;
            options.ipopt.max_iter    = 200;
            options.ipopt.constr_viol_tol = obj.option.tol;
            % state variable in global step
            dx_SX = SX.sym('dx',Nx,1);
            s_SX  = SX.sym('dx',Nlam,1);
%                 extended variable - X = [dx; s]
            X_SX  = vertcat(dx_SX,s_SX);       
            % objective in global step
            objective_fun =   X_SX'*obj.HQP*X_SX/2 + obj.gQP'*X_SX;
            % linear constraint in global step
            con_fun       =   obj.AQP*X_SX - obj.bQP;
            % initialize casadi model
            nlp_casadi    = struct('x',X_SX,'f',objective_fun,'g',con_fun);
            casadi_model  = nlpsol('solver','ipopt',nlp_casadi,options);
            sol   = casadi_model('x0',   obj.Y0,...
                                 'lbx',  obj.lbdy,...
                                 'ubx',  obj.ubdy,...
                                 'lbg',  obj.lbg,...
                                 'ubg',  obj.ubg);
            xopt = full(sol.x);
            % primal & dual step
            dy   = xopt(1:Nx);
            dlam = full(sol.lam_g(1:Nlam))-lam;
        end
    end
end

