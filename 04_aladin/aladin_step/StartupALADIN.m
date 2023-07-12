classdef StartupALADIN
    %StepALADIN contains all steps of ALADIN algorithm
    %   including 1. local NLP step 
    %             2. termination step
    %             3. global QP step
    %             4. primal dual variable updating step
    
    properties
        nlp           localNLP     % local Non-Linear Problem
        qp            globalQP     % global Quadratic Problem
        idx_ang                    % entries of angle varibles
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
                flag_angle         = false;
                for i = 1:obj.Nregion
                    if ~isempty(nlp(i).ceq)
                        obj.Nkappa = obj.Nkappa + numel(nlp(i).ceq(x0{i}));
                    end
                    if ~isempty(nlp(i).cineq)
                        obj.Nkappa = obj.Nkappa + numel(nlp(i).cineq(x0{i}));
                    end
                    if any(nlp(i).idx_ang)
                        flag_angle = true;
                    end
                end
                if flag_angle
                    obj.idx_ang = vertcat(nlp(:).idx_ang);
                else
                    obj.idx_ang = [];
                end
%                 obj.kappai         = cell(obj.Nregion,1);
                % initialize logg to record data in iteration
                obj.logg           = iterInfo(option.iter_max, obj.Nx, obj.Nlam, obj.Nregion);
                obj.logg.mu(1)     = option.mu0;
                obj.logg.rho(1)    = option.rho0;
                % updating global & local setting
                obj.option         = update_option_setting(option, nlp(1).option);
                % initial casadi model for global QP step
%                 if strcmp(obj.option.qp.solver, 'casadi')
%                     obj.global_casadi_model  = obj.build_global_model_casadi;
%                 end
            end
        end
        
        % Method 1
        function [yi,sensitivities,logg] = local_step(obj,xi,lam)
            %% 1. solve local NLP problems in all regions
            % obtain primal minimizers of local problem and relevent sensitivities, including Hessian and gradient of original local cost function
            % INPUT
            % xi  - primal variables of current region
            % lam - dual variables
            logg                          = obj.logg;
            k                             = logg.iter;
            rho                           = logg.rho(k);
            % initial sensitivities array of localSensitivities Class
            sensitivities(obj.Nregion,1)  = localSensitivities;
            % initial local state variable
            yi                            = cell(obj.Nregion,1);
            fval = 0;
            for j = 1:obj.Nregion
                tic
                % solve local NLPs, obtain yi and sensitivities info
%                 if obj.nlp(j).option.iter_display
%                     fprintf('\nstart NLP of region %d\n\n',j)
%                 end
                [yi{j},sensitivities(j)]  = obj.nlp(j).solve_local_NLP(xi{j},lam,rho);
                % angle issue - wrap angle variables to [-pi, pi], if they are not in the interval
%                 if ~isempty(sensitivities(j).fval)
%                     fval = fval+sensitivities(j).fval;
%                 end
                logg.et.local(j,k)=toc;
               logg.delta(k) = logg.delta(k)+obj.nlp(j).local_funs.fi(yi{j});
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
            if logg.primal_feasibility(k)<=tol %&& logg.dual_feasibility(k)<=tol
                flag = 1;
            else
                flag = 0;
            end
        end
        
        % Method 3
        function [dy,dlam] = global_step(obj,sensitivities, lam, consensus_residual)
            %% 3. solve global QP problem
            % initialize QP problem
            % INPUT
            % sensitivities - array of localSensitivities class
            % lam           - dual variables
            % consensus_residual - residual of consensus
            % idx           - entries of angle varibles
%             fprintf('\nstart QP \n')
            k                  = obj.logg.iter;
            % pre-processing for QP problem 
            obj.qp             = globalQP(obj,sensitivities,consensus_residual,lam);
            % solve equivalent linear system
            [dy,dlam]   = obj.qp.solve_global_qp(obj.Nlam, obj.Nx, lam);            
            % wrap angle variable into interval [-pi, pi]
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
                if ~isempty(obj.idx_ang)
                    X_plus = wrap_ang_variable(X_plus,obj.idx_ang);
                end
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