function [L, dLdx, d2Ldx] = build_local_lagrangian_function(f, df, g, dg, h, dh)
%BUILD_LOCAL_LAGRANGIAN_FUNCTION Builds the Lagrangian of the local mpc file
%   kappa is [lambda; mu] with lambda, mu are column vectors
% dg is the transposed of the jacobian of g, i.e. dimension nx_x \times n_eq 
% dh is the transposed jacobian of h
% L = f + lambda'g + mu'h
% dL = grad_f + lambda'(Jac_g)' + mu'(Jac_h)'

    if nargin == 4
        L = @(x, kappa, Neq) f(x) + kappa(1:Neq)'*g(x);
        dLdx = @(x, kappa, Neq) df(x) ...
            + get_grad_lambda_g(kappa(1:Neq), dg, x);
        d2Ldx = @(x, kappa, rho, Neq)  get_Hess(dLdx, x, kappa, Neq);
    elseif nargin == 6
        L = @(x, kappa, Neq) f(x) + kappa(1:Neq)'*g(x) + kappa(Neq+1:end)'*h(x);
        dLdx = @(x, kappa, Neq) df(x)  + ...
            get_grad_lambda_g(kappa(1:Neq), dg, x) + ...
            get_grad_mu_h(kappa(Neq+1:end), dh, x);
        d2Ldx = @(x, kappa, rho, Neq) get_Hess(dLdx, x, kappa, Neq);
    end


% L = @(x, kappa, Neq) f(x) + kappa(1:Neq)'*g(x) + kappa(Neq+1:end)'*h(x);
% dLdx = @(x, kappa, Neq) df(x)  + ...
%    get_grad_lambda_g(kappa(1:Neq), dg, x) + ...
%    get_grad_mu_h(kappa(Neq+1:end), dh, x);
% d2Ldx = @(x, kappa, rho) get_Hess(dLdx, x, kappa, Neq);

end

%% get gradient of lambda'*g
function grad_lambda_g = get_grad_lambda_g(lambda, dg, x) 
    grad_lambda_g = sparse(length(x), 1);
    dg_at_x = dg(x);
    for i = 1 : length(lambda)
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
function d2Ldx = get_Hess(dLdx, x, kappa, Neq)
epsilon = 1e-10;
epsilon_inv = 1/epsilon;
nx = length(x);
d2Ldx = zeros(nx, nx);
for i = 1 : nx
    dx_i = [ zeros(i-1, 1); 1; zeros(nx-i, 1)];
    d2Ldx(:, i) = (dLdx(x + epsilon*dx_i, kappa, Neq) ...
        - dLdx(x - epsilon*dx_i, kappa, Neq)).*0.5.*epsilon_inv;
end
end
