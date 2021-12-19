classdef NLPoption
    %NLPOPTION options for local solver
    %   support fmincon, fminunc, lsqnonlin
    
    properties
        solver      char {mustBeMember(solver,{'fmincon', 'fminunc','lsqnonlin','casadi'})}   = 'fmincon'         % select solver
        sens        char {mustBeMember(sens,{'specify', 'casadi'})}   = 'casadi'
        con_type    char {mustBeMember(con_type,{'unconstrained','eq', 'ineq','both'})}       = 'unconstrained'   % problem type of local NLPs
        constrained          logical = false % if problem is unconstrained
        specify_obj_grad     logical = true  % providing specify objective gradient
        specify_lag_hess     logical = true  % providing specify hessian of lagrangian
        specify_con_jac      logical = false % providing specify jacobian of constraints
        tol                          = 1e-8
        iter_display         logical = true  % display iter information of local solver
        active_set           logical = true  % using active set to handel ineq
    end
    
    methods
        function obj = NLPoption(option)
            %NLPOPTION Construct an instance of this class
            %   Detailed explanation goes here
            if nargin>0
                obj = option;
                if strcmp(solver, 'casadi')
                    obj.sens = 'casadi';
                    obj.specify_obj_grad = false;
                    obj.specify_lag_hess = false;
                    obj.specify_con_jac  = false;
                end
            end
        end
    end
end

