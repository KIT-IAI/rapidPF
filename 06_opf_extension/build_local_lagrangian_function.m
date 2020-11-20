function [L, dLdx, d2Ldx] = build_local_lagrangian_function(f, df, g, dg, h, dh)
%BUILD_LOCAL_LAGRANGIAN_FUNCTION Bulds the Lagrangian of the local mpc file
%   kappa is [lambda; mu] with lambda, mu are column vectors
% dg is the transposed of g, i.e. dimension nx_x \times n_eq 
% dh is the transposed jacobian of h
% L = f + lambda'g + mu'h
% dL = grad_f + lambda'(dg)' + mu'(dh)'
    if nargin == 4
        L = @(x, kappa, Neq) f(x) + kappa(1:Neq)'*g(x);
        dLdx = @(x, kappa, Neq) df(x)  + (kappa(1:Neq)'*dg(x)')';
        d2Ldx = @(x, kappa, rho, Neq) get_Hess(dLdx, x, kappa(1:Neq), kappa(Neq + 1: end));
    elseif nargin == 6
        L = @(x, kappa, Neq) f(x) + kappa(1:Neq)'*g(x) + kappa(Neq+1:end)'*h(x);
        dLdx = @(x, kappa, Neq) df(x)  + (kappa(1:Neq)'*dg(x)')' + (kappa(Neq+1:end)'*dh(x)')';
        d2Ldx = @(x, kappa, rho, Neq) get_Hess(dLdx, x, kappa(1:Neq), kappa(Neq + 1: end));
    end
end

%% get Hessian Function
function d2Ldx = get_Hess(dLdx, x, lambda, mu)
    epsilon = 1e-10;
    epsilon_inv = 1/epsilon;
    nx = length(x);
    d2Ldx = sparse(nx, nx);
    
    kappa = [lambda; mu];
    Neq = numel(lambda);
    
    for i = 1 : nx
        dx_i = [ zeros(i-1, 1); 1; zeros(nx-i, 1)];
        d2Ldx(:, i) = (dLdx(x + epsilon*dx_i, kappa, Neq) ...
            - dLdx(x - epsilon*dx_i, kappa, Neq)).*0.5.*epsilon_inv;
    end
end
