classdef localSensitivities
    %LOCALSENSITIVITIES Summary of this class goes here
    %   Detailed explanation goes here
    properties
        Hess    % Hessian of objective func for local regions
        grad    % gradient of objective func for local regions
        jacobian    % jacobian of equality constraints for local regions
        ubdy
        lbdy
        
    end
    methods
        function obj = localSensitivities(nlp,yi,lambda)
            if nargin > 0
                tol = sqrt(nlp.option.tol);
                % computing sens by casadi
%                 if isempty(nlp.casadi_model)
                    %% assumption: only have equality & inequality nonlinear constraints  
                    % not be validated yet
                    % jacobian for boundarys in active set
    %                 jacobian_bound = evaluate_jac_bound_active_set(nlp.lby,nlp.uby,yi,tol);
                    switch nlp.option.con_type
                        case 'unconstrained'
                            kappa = 0;
                            % jacobian of constraints
                            jacobian_ceq   = [];
                            jacobian_cineq = [];
                        case 'eq'
                            %% currently set to zero for feasibility problem in rapidPF
                            kappa = lambda.eqnonlin;
    %                         kappa=zeros(size(lambda.eqnonlin));
                            % jacobian of constraints
                            jacobian_ceq   = nlp.jac_ceq(yi);
                            jacobian_cineq = [];
%                             kappa = zeros(size(kappa));
                        case 'ineq'
                            kappa = lambda.ineqnonlin;
                            % jacobian of constraints
                            jacobian_ceq   = [];
                            jacobian_cineq = evaluate_jac_ineq_active_set(nlp,yi,tol);
                        case 'both'
                            % equality comes first
                            kappa = vertcat(lambda.eqnonlin, lambda.ineqnonlin);
                            % jacobian of constraints
                            jacobian_ceq   = nlp.jac_ceq(yi);
                            jacobian_cineq = evaluate_jac_ineq_active_set(nlp,yi,tol);
                    end
                    % jacobian
                    obj.jacobian = vertcat(jacobian_ceq,jacobian_cineq);
                    % gradient
                    obj.grad     = nlp.local_funs.gi(yi); 
                    % hessian of lagrangian
                    
                    obj.Hess     = nlp.local_funs.hi(yi,kappa);                    
%                 else
%                     %% using casadi to compute senstivities
%                     % active set detecting
%                     if ~isempty(nlp.cineq)
%                         active_set_ineq = detect_active_set_inequality(nlp.cineq,yi,tol); % inequality constraint on boundary
%                         active_set_eq   = true(nlp.Nkappai.eq,1);                         % all equality constraint
%                         active_set      = vertcat(active_set_ineq,active_set_eq);
%                         lambda          = active_set.*lambda;
% %                     else
% %                         lambda = zeros(size(lambda));
%                     end
%                     % compute sens by using casadi
%                     [grad, jac, Hess] = nlp.casadi_model.sens(yi,lambda);
%                     obj.grad          = full(grad);
%                     obj.jacobian      = full(jac);
%                     if ~isempty(nlp.cineq)
%                         % changing array size - may slow down 
%                         obj.jacobian  = obj.jacobian(active_set,:);
%                     end
%                     obj.Hess      = full(Hess);
%                 end
                % step limit on dy
                obj.lbdy     =nlp.lby - yi; 
                obj.ubdy     =nlp.uby - yi;
            end
        end
    end
end

function jacobian_bound = evaluate_jac_bound_active_set(lbx,ubx,x,tol)
% check active set for boundary, return jacobian of bound in active set
    eye_bound      = speye(numel(x));
    % select the row which violate either upper bound or lower bound
    jacobian_bound = eye_bound(((x-lbx)<-tol) | ((x-ubx)>-tol),:);
%     if any(jacobian_bound)
%         keyboard
%     end
end

function active_set = detect_active_set_inequality(cineq,x,tol)
% check active set for inequality constraints, return jacobian of inequality constraints in active set
    active_set            = cineq(x)>-tol;
end

function jacobian_active = evaluate_jac_ineq_active_set(nlp,x,tol)
% check active set for inequality constraints, return jacobian of inequality constraints in active set
    active_set = detect_active_set_inequality(nlp.cineq,x,tol);
    jacobian   = nlp.jac_cineq(x);
    jacobian_active = jacobian(active_set,:);
end