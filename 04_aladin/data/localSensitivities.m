classdef localSensitivities
    %LOCALSENSITIVITIES Summary of this class goes here
    %   Detailed explanation goes here
    properties
        Hess    % Hessian of objective func for local regions
        JJp
        grad    % gradient of objective func for local regions
        jacobian    % jacobian of equality constraints for local regions
        ubdy
        lbdy
        fval
        
    end
    methods
        function obj = localSensitivities(nlp,yi)
            if nargin > 0
                tol = sqrt(nlp.option.tol);
                % computing sens by casadi
%                 if isempty(nlp.casadi_model)
                %% assumption: only have equality & inequality nonlinear constraints  

%                     obj.Hess     = nlp.local_funs.hi(yi,kappa);      
                [obj.grad, obj.JJp, obj.Hess ] = nlp.local_funs.sens(yi); 

                obj.lbdy     =nlp.lby - yi; 
                obj.ubdy     =nlp.uby - yi;
            end
        end
    end
end

function active_set = detect_active_set_inequality(cineq,x,tol)
% check active set for inequality constraints, return jacobian of inequality constraints in active set
    active_set            = cineq(x)>-tol;
end
