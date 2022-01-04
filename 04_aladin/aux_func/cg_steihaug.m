function x = cg_steihaug(A,b,toltol,maxit,delta)
% lin
% check alg options
if nargin < 3 || isempty(toltol), toltol = 1e-12; end
if nargin < 4 || isempty(maxit), maxit = min(20,length(b)); end
if nargin < 5 || isempty(delta), delta = []; end

% intial
x = zeros(size(b));
r = -b;  
% without preconditioning
p = -r;
rr = r'*r;
% [obj.HQP(p), obj.AQP'; obj.AQP, obj.KQP]
if isa(A,'function_handle')
    Ap = A(p);
else
    Ap = A*p;   
end
i = 0;
    while max(abs(r))>toltol &&  i<=maxit
        % A always positive defined
        if ~isempty(delta) && p'*Ap <= 0  
            % 1. terminate when negative defined A, return cauchy-point
            tau = find_steplength_on_edge(x,p,delta);
            x   = x + tau * p;
%             i
%             flag = 1
            return 
        end
        rho = rr/(p'*Ap);       % one-dim minimizer
        xk  = x;
        x   = x + rho*p;        % update state
%         if ~isempty(delta) && x'*x > delta^2 
%             % 2. terminate when new step encounters edge of trust-region
%             tau = find_steplength_on_edge(xk,p,delta);
%             x   = xk + tau * p;
%             i
%             flag = 2
%             return
%         end
        r      = r + rho*Ap;       % update residual
        rr_new = r'*r;
        if rr_new<toltol
            % 3. terminate when reach CG solution within trust region
%             i
%             flag = 3
            return
        end
        beta   = rr_new/rr;      % update the parameter to ensure conjugate 
        rr  = rr_new;
        p   = -r + beta*p;
        if isa(A,'function_handle')
            Ap = A(p);
        else
            Ap = A*p;   
        end
        i   = i+1;
    end
    i
end

function tau = find_steplength_on_edge(x,p,delta)
    % tau = arg_tau ||x + tau*p||_M = delta
    xx  = x'*x;
    pp  = p'*p;
    xp  = x'*p;
    tau = (-xp + sqrt(xp^2+pp*(delta^2-xx)))/pp; %7.5.5 Trust Region Methods, SIAM
end
