function jac = jacobian_num(f, x, nf, nx, epsilon)
    % calculate jacobian of `f` at `x`
    % use central differences with step size `epsilon`
    % nf -- number of entries in `f`
    % nx -- number of entries in `x`
    if nargin == 4
        epsilon = 1e-8;
    end
    epsilon_inv = 1/epsilon;
    jac = zeros(nf, nx);

    for i = 1:nx
        dx = [ zeros(i-1,1); 1; zeros(nx-i,1)] ;
        jac(:, i) = (feval(f, x + epsilon*dx) - feval(f, x - epsilon*dx)) .* 0.5 .* epsilon_inv;
    end
end