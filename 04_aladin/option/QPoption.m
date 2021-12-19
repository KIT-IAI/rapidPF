classdef QPoption
    %QPOPTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        solver               char {mustBeMember(solver,{'casadi','lsqlin','lsqminnorm','linsolve','pinv','ldl','lu','quadprog'})} = 'lsqminnorm' % solver of QP problem
        tol                          = 1e-8
        iter_display         logical = true        
        constrained          logical = false % if problem is unconstrained
        specify_obj_grad     logical = true  % providing specify objective gradient
        specify_lag_hess     logical = true  % providing specify objective hessian
        specify_con_jac      logical = true  % providing specify objective hessian
        regularization_hess  logical = false % Hessian Regularization
    end
    
    methods
        function obj = QPoption(inputArg1,inputArg2)
            %QPOPTION Construct an instance of this class
            %   Detailed explanation goes here
            if nargin>0
                obj.Property1 = inputArg1 + inputArg2;
            end
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

