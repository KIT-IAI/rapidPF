classdef originalFuns
    %LOCALFUN contains information of original cost function
    %   including cost, gradient, hessian and consensus matrix
    
    properties
        % original cost
        fi % original local cost function
        gi % gradient of the local cost function
        hi % hessian  of the local cost function
        Ai % consensus matrix for current region
        sens
        
        % residual
        ri  % residual function
        dri % gradient of residual function
        
        % constraints
        ceq                % equality constraints
        jac_ceq            % jacobian matrix of equality constraints
        hess_ceq           % 
        
        cineq              % equality constraints
        jac_cineq          % jacobian matrix of equality constraints
        hess_cineq         %     
    end
    
    methods
        function obj = originalFuns(fi, sens, Ai, ri, dri, con_eq, jac_eq, con_ineq, jac_inq)
            %LOCALFUN Construct an original funs for a region
            if nargin>0
                obj.fi = fi;
                obj.sens = sens;
                obj.Ai = sparse(Ai);
                if ~isempty(ri) && ~isempty(dri)
                    obj.ri = ri;
                    obj.dri = dri;
                end
                if ~isempty(con_eq) && ~isempty(jac_eq)
                    obj.ceq = con_eq;
                end
                if ~isempty(jac_eq)
                    obj.jac_ceq = jac_eq;
                end                
                if ~isempty(con_ineq)
                    obj.cineq = con_ineq;
                end
                if ~isempty(jac_inq)
                    obj.jac_cineq = jac_inq;
                end                    
                

            end
        end
    end
end

