function [L, dLdx, d2Ldx] = build_local_lagrangian_function(f, df, g, dg, h, dh)
%BUILD_LOCAL_LAGRANGIAN_FUNCTION Bulds the Lagrangian of the local mpc file
%   lambda, mu are a column vectors
% dg is the transposed of g, i.e. dimension nx_x \times n_eq 
% dh is the transposed jacobian of h
% L = f + lambda'g + mu'h
% dL = grad_f + lambda'(Jac_g)' + mu'(Jac_h)'
L = @(x, lambda_g, mu_h) f(x) + lambda_g'*g(x) + mu_h'*h(x);
dLdx = @(x, lambda_g, mu_h) df(x)  + (lambda_g'*dg(x)')' + (mu_h'*dh(x)')';
d2Ldx = @(x, lambda_g, mu_h, rho) get_Hess(dLdx, x, lambda_g, mu_h);

end


%% get Hessian Function
function d2Ldx = get_Hess(dLdx, x, lambda, mu)
epsilon = 1e-10;
epsilon_inv = 1/epsilon;
nx = length(x);
d2Ldx = zeros(nx, nx);
for i = 1 : nx
    dx_i = [ zeros(i-1, 1); 1; zeros(nx-i, 1)];
    d2Ldx(:, i) = (dLdx(x + epsilon*dx_i, lambda, mu) ...
        - dLdx(x - epsilon*dx_i, lambda, mu)).*0.5.*epsilon_inv;
end
end
