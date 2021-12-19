classdef StartupALADIN
    %StepALADIN contains all steps of ALADIN algorithm
    %   including 1. local NLP step 
    %             2. termination step
    %             3. global QP step
    %             4. primal dual variable updating step
    
    properties
        nlp           localNLP     % local Non-Linear Problem
        qp            globalQP     % global Quadratic Problem
        A                          % consensus matrix      Ax=b
        b                          % consensus constraints Ax=b
        Nx                         % number of primal variable
        Nlam                       % number of dual variable - lagrangian multiplier for consensus constraints
        Nkappa                     % number of all equality & inequality constraints
        Nregion                    % number of subsystems
        logg          iterInfo     % temporary data in iterations
        option        AladinOption % option for ALADIN algorithm
    end
    
    methods
        % constructor
        function obj = StartupALADIN(nlp,x0,A,b,option)
            %% Construct a framework for ALADIN algorithm
            % setting option, initial local NLP problem and create an object for iter information 
            % INPUT
            %   nlp    - array of localNLP class
            %   A      - consensus constraints Ax-b=-8
            %   b      - consensus constratins Ax-b=0
            %   option - option setting for ALADIN algorithm
            if nargin >0
                obj.nlp            = nlp;
                % consensus matrix
                obj.A              = A;
                obj.b              = b;
                [obj.Nlam, obj.Nx] = size(A);
                obj.Nregion        = numel(nlp);
                % number of equality & inequality constraints
                obj.Nkappa         = 0;
                for i = 1:obj.Nregion
                    if ~isempty(nlp(i).ceq)
                        obj.Nkappa = obj.Nkappa + numel(nlp(i).ceq(x0{i}));
                    end
                    if ~isempty(nlp(i).cineq)
                        obj.Nkappa = obj.Nkappa + numel(nlp(i).cineq(x0{i}));
                    end
                end
%                 obj.kappai         = cell(obj.Nregion,1);
                % initialize logg to record data in iteration
                obj.logg           = iterInfo(option.iter_max, obj.Nx, obj.Nlam);
                obj.logg.mu(1)     = option.mu0;
                obj.logg.rho(1)    = option.rho0;
                % updating global & local setting
                obj.option         = update_option_setting(option, nlp(1).option);
                % initial casadi model for global QP step
                if strcmp(obj.option.qp.solver, 'casadi')
%                     obj.global_casadi_model  = obj.build_global_model_casadi;
                end
            end
        end
        
        % Method 1
        function [yi,sensitivities,idx_ang] = local_step(obj,xi,lam)
            %% 1. solve local NLP problems in all regions
            % obtain primal minimizers of local problem and relevent sensitivities, including Hessian and gradient of original local cost function
            % INPUT
            % xi  - primal variables of current region
            % lam - dual variables
            k                             = obj.logg.iter;
            rho                           = obj.logg.rho(k);
            % initial sensitivities array of localSensitivities Class
            sensitivities(obj.Nregion,1)  = localSensitivities;
            % initial local state variable
            yi                            = cell(obj.Nregion,1);
            flag = false;
            for j = 1:obj.Nregion
                % solve local NLPs, obtain yi and sensitivities info
                fprintf('\nstart NLP of region %d\n\n',j)
                [yi{j},sensitivities(j)]  = obj.nlp(j).solve_local_NLP(xi{j},lam,rho);
                % angle issue - wrap angle variables to [-pi, pi], if they are not in the interval
                if any(obj.nlp(j).idx_ang) 
                    yi{j}                 = wrap_ang_variable(yi{j},obj.nlp(j).idx_ang);
                    flag                  = true;
                end
            end
            % vertcat all entries of angle varibles, specify for PF/OPF
            if flag
                idx_ang = vertcat(obj.nlp(:).idx_ang);
            else
                idx_ang = [];
            end
        end     
        
        % Method 2
        function [flag, consensus_residual, logg] = check_termination_condition(obj,xi,yi)
            %% 2. check primal-&dual-feasibility
            %   primal feasibility: ||Ax-b||< tol
            %   dual feasibility:   rho ||y-x||< tol
            % INPUT
            % xi  - initial point of NLP
            % yi  - optimizer of NLP
            logg        = obj.logg;
            k           = logg.iter;
            tol         = obj.option.tol;
            rho         = logg.rho(k);
            logg.Y(:,k) = vertcat(yi{:});
            logg.X(:,k) = vertcat(xi{:});
            logg.iter   = k;
            % residual vector of consensus constraint
            consensus_residual         = obj.A*logg.Y(:,k)-obj.b;
            % primal feasibility
            logg.primal_feasibility(k) = max(abs(consensus_residual));
            logg.local_steplength(k)   = max(abs(logg.Y(:,k) - logg.X(:,k)));
            % dual feasibility
            logg.dual_feasibility(k)   = rho * logg.local_steplength(k);   
            % check if primal & dual feasibility are satisfied
            if logg.primal_feasibility(k)<=tol && logg.dual_feasibility(k)<=tol
                flag = 1;
            else
                flag = 0;
            end
        end
        
        % Method 3
        function [dy,dlam] = global_step(obj,sensitivities, lam, consensus_residual, idx_ang)
            %% 3. solve global QP problem
            % initialize QP problem
            % INPUT
            % sensitivities - array of localSensitivities class
            % lam           - dual variables
            % consensus_residual - residual of consensus
            % idx           - entries of angle varibles
            fprintf('\nstart QP \n')
            k                  = obj.logg.iter;
            % pre-processing for QP problem 
            obj.qp             = globalQP(obj,sensitivities,consensus_residual,lam);
            % solve equivalent linear system
            [dy,dlam]   = obj.qp.solve_global_qp(obj.Nlam, obj.Nx, lam);            
            % wrap angle variable into interval [-pi, pi]
            if ~isempty(idx_ang)
                dy             = wrap_ang_variable(dy,idx_ang);
            end
        end        
        
        % Method 4
        function [x_plus,lam,logg] = primal_dual_update(obj,yi,dy,lam,dlam)
            %% 4. updating primal and dual variables
            %   currently updating with full-step
            % INPUT
            % yi, lam  - primal & dual variables
            % dy, dlam - step of primal & dual variables
            % extract data from main loop
            logg      = obj.logg;
            k         = logg.iter;
%             if k <2
%                 X_plus    = logg.X(:,k);
%             else
                X_plus    = logg.Y(:,k)+dy;
%             end
            % update primal variable
            % assign new state to xi
            idx_x_start   = 1;
            idx_kappa_start = 1;
            x_plus        = cell(obj.Nregion,1);
            kappai        = cell(obj.Nregion,1);
            for j = 1:obj.Nregion
                % reassign to local nlp - x
                Nxi       = numel(yi{j});
                idx_x_end = idx_x_start + Nxi - 1;
                x_plus{j} = X_plus(idx_x_start:idx_x_end);
                idx_x_start = idx_x_end + 1;
            end
            % update dual variable
            lam = lam+dlam;
            logg.Z(:,k)   = logg.X(:,k);
            logg.X(:,k)   = X_plus;
%             logg.kappa(:,k) = kappa;
            logg.global_steplength(k) = max(abs(dy));
            logg.lam(:,k) = lam;
%             cost = obj.nlp(1).local_funs.fi(x_plus{1}) + obj.nlp(2).local_funs.fi(x_plus{2})
        end
        
        function flag = check_trap_in_loop(obj)
            k  = obj.logg.iter;
            dx = max(abs(obj.logg.X(:,k)-obj.logg.X(:,k-1)));
            dy = max(abs(obj.logg.Y(:,k)-obj.logg.Y(:,k-1)));
            if  dx < obj.option.tol && dy<obj.option.tol
                flag = 2;
            else
                flag = 0;
            end
        end
    end
end

function x = wrap_ang_variable(x,idx_ang)
    % wrap angle variables to [-pi, pi], if they are not in the interval
    % x       - state variable
    % idx_ang - logical array represents entries of angle variable 
    if any((x(idx_ang)<-pi) | (x(idx_ang)>pi))
        x(idx_ang) = wrapToPi(x(idx_ang));
    end
end

% update option setting by local NLP setting
function alg_option = update_option_setting(alg_option,local_option)
%% assumption: NLPs in different region have the same local setting
    alg_option.nlp                 = local_option;
    % update setting for global
    alg_option.qp.tol              = local_option.tol;
    alg_option.qp.iter_display     = local_option.iter_display;
    alg_option.qp.constrained      = local_option.constrained;
    alg_option.qp.specify_obj_grad = local_option.specify_obj_grad;
    alg_option.qp.specify_lag_hess = local_option.specify_lag_hess;
    alg_option.qp.specify_con_jac  = local_option.specify_con_jac;
    alg_option.active_set          = local_option.active_set;
end

%% trust region method / sufficient descent check
%             H    =  blkdiag(sensitivities(:).HHi);
%             grad = sparse(vertcat(sensitivities(:).gfi)+A'*lam);
%
%         function [dy,dlam,logg] = trust_region_method(obj,dy,dlam,A,logg, H, grad, i,xi,x_plus)
% %             pk = vertcat(dy,dlam);
%             pk = dy;
%             pp = pk'*pk;
%             gg = grad'*grad;
%             if i==1
%                 d = gg/(grad'*H*grad);
%                 logg.delta(i) = d;
%                 dd = d^2;
%             else
%                 dd = logg.delta(i)^2;
%             end
%             success = check_sufficient_descent(obj,A,xi,x_plus,i);
%             if success
%                % full step, increase delta
%                     logg.delta(i) = max( 2 * sqrt(pp),logg.delta(i));
%               
%             else
%                      logg.delta(i) = sqrt(pp)/4;
%             end
%             if pp > dd
%                 p_sd = -(grad'*grad)/(grad'*H*grad)* grad; % steepest descent direction
%                 pp_sd = p_sd'*p_sd;
%                 if pp_sd > dd
%                     beta =  sqrt(dd/pp_sd);
%                     pk   = beta*p_sd;
%                 else
%                     % dogleg
%                     dp = pk-p_sd;
%                     c  = p_sd'*dp;
%                     if c<=0
%                         beta = (-c + sqrt(c^2+dp'*dp*(dd-pp_sd))) / (dp'*dp);
%                     else
%                         beta = (dd-pp_sd)/(c+sqrt(c^2+dp'*dp*(dd-pp_sd)));
%                     end
%                     pk  = p_sd + beta * dp;
%                 end
%                 Nx = numel(dy);
%                 dy = pk(1:Nx);
% %                 dlam = beta * dlam;
% %                 dlam = pk((Nx+1):end);   
%             end
%             if i<numel(logg.delta)
% 
%                 logg.delta(i+1) = logg.delta(i);
%             end
%         end
% % 
% function flag = check_sufficient_descent(obj,A,xold,xnew,i)
%     logg    = obj.logg;
%     p_local = logg.Y(:,i)-logg.X(:,i);
%     gamma   = 0.1;
%     lambda  = 100;
%     Nregion = numel(xold);
%     Xnew = vertcat(xnew{:});
%     Xold = vertcat(xold{:});
%     dphi = 0;
%     for j = 1:Nregion
%         dphi = dphi + obj.nlp(j).local_funs.fi(xold{j})-obj.nlp(j).local_funs.fi(xnew{j});
%     end
%     dphi =  dphi + max(abs(A*Xold)) -max(abs(A*Xnew)) - gamma *( 500 * p_local'*p_local +  max(abs(lambda* A *logg.Y(:,i))));
%     if dphi>0
%         flag = true;
%     else
%         flag = false;
%     end
% end
% 
% function phi = phi_fun(fi,xi,Ai,ceq)
%     
%     for j = 1:Nregion
%         dphi = dphi + obj.nlp(j).local_funs.fi(xold{j})-obj.nlp(j).local_funs.fi(xnew{j});
%     end
% end


%             flag = check_sufficient_descent(obj,A,xi,x_plus,i)
%             if flag
%                 obj.gamma = obj.gamma/2;
%             else
%                 obj.gamma = obj.gamma*2;
%             end
%             % trust region
%             
%             [dy,dlam, obj.logg] = trust_region_method(obj,dy,dlam,A,obj.logg,H, grad,i,xi,x_plus);
%             X_plus  = obj.logg.Y(:,i)+dy;
% %             s = A*X_plus;
% % % %             ss = s'*s;
% %             dlam = s*mu;
%             idx_start = 1;
%             for j = 1:Nregion
%                 Nxi       = numel(yi{j});
%                 idx_end   = idx_start + Nxi - 1;
%                 x_plus{j} = X_plus(idx_start:idx_end);
%                 idx_start = idx_end + 1;
%             end       