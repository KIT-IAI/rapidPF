function [L, dLdx, d2Ldx] = build_local_lagrangian_function(f, df, g, dg, h, dh, state)
%BUILD_LOCAL_LAGRANGIAN_FUNCTION 
%
%  `Builds the Lagrangian of the local mpc file`
%   
%  INPUT: 
%         - $\texttt{f}$ scalar valued cost function
%         - $\texttt{df}$ gradient of $\textt{f}$ 
%         - $\texttt{g}$ equality constraints
%         - $\texttt{dg}$ transposed jacobian of the 'reduced' equality constraints
%         - $\ŧexttt{h}$ inequality constraints
%         - $\texttt{dh}$ transposed jacobian of the inequality constraints
% 
%  OUTPUT:
%         - $\texttt{L}$ 'reduced' Lagrangefunction
%         - $\texttt{dLdx}$ grandient of the Lagrangian
%         - $\ŧexttt{d2Ldx}$ hessian of the Lagrangian
%
%  REMARK:
%   mu is the langrange multiplier for the 
%   kappa = [lambda; mu] (with lambda, mu column vectors)
%   L = f + lambda'g + mu'h
%   dL = grad_f + \sum lambda_i (Jac_g)'(:, i) + \sum mu_i(Jac_h)'(:, i)

x = zeros(length(state), 1);
Neq = numel(g(x));
Nineq = numel(h(x));
    
if Neq > 0 && Nineq == 0
        L       = @(x, kappa) f(x) * kappa'*g(x);
        dLdx    = @(x, kappa) df(x) + get_grad_lambda_g(kappa, dg, x);
        d2Ldx   = @(x, kappa, rho, Neq)get_Hess(dLdx, x, kappa);
elseif Neq == 0 && Nineq > 0 
        L       = @(x, kappa) f(x) * kappa'*h(x);
        dLdx    = @(x, kappa) df(x) + get_grad_mu_h(kappa, dh, x);
        d2Ldx   = @(x, kappa, rho, Neq)get_Hess(dLdx, x, kappa);
elseif Neq > 0 && Nineq > 0 
        L       = @(x, kappa) f(x) * kappa(1:Neq)'*g(x) + kappa(Neq + 1:end)'*h(x);
        dLdx    = @(x, kappa) df(x) + get_grad_lambda_g(kappa(1:Neq), dg, x) + get_grad_mu_h(kappa(Neq+1:end), dh, x);
        d2Ldx   = @(x, kappa, rho, Neq)get_Hess(dLdx, x, kappa);
end

%% get gradient of lambda'*g
function grad_lambda_g = get_grad_lambda_g(lambda, dg, x) 
    grad_lambda_g = sparse(length(x), 1);
    dg_at_x = dg(x);
    for i = 1 : size(dg_at_x, 2)
        grad_lambda_g = grad_lambda_g + lambda(i)*dg_at_x(:, i);
    end
end
%% get gradient of mu'*h
function grad_mu_h = get_grad_mu_h(mu, dh, x)
    grad_mu_h = sparse(length(x), 1);
    dh_at_x = dh(x);
    for i = 1 : length(mu)
        grad_mu_h = grad_mu_h + mu(i)*dh_at_x(:, i);
    end
end

%% get Hessian Function
function d2Ldx = get_Hess(dLdx, x, kappa)
    epsilon = 1e-10;
    epsilon_inv = 1/epsilon;
    nx = length(x);
    d2Ldx = zeros(nx, nx);
    for i = 1 : nx
        dx_i = [ zeros(i-1, 1); 1; zeros(nx-i, 1)];
        d2Ldx(:, i) = (dLdx(x + epsilon*dx_i, kappa) ...
            - dLdx(x - epsilon*dx_i, kappa)).*0.5.*epsilon_inv;
    end
end

end
