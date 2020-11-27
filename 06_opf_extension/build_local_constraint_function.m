function [constraint_function, Lxx] = build_local_constraint_function(mpc_opf, om, mpopt)
    %BUILD_LOCAL_CONSTRAINT_FUNCTION extracts matpower equality and
    %inequality constraints and their jacobian to rapidOPF
    %
    %Output: - constraint_function @(x)[h, dh, g, dh]
    %        - Lxx Lagrangian function of complete system in MATPOWER. It
    %          is not usable by rapidOPF but taken for completeness
    %       
    [Ybus, Yf, Yt] = makeYbus(mpc_opf);
    il = find(mpc_opf.branch(:, 6) ~= 0 & mpc_opf.branch(:, 6) < 1e10);
    
    constraint_function = @(x)opf_consfcn(x, om, Ybus, Yf(il,:), Yt(il,:), mpopt, il);
    % cost multiplier is set to one
    cost_mult = 1;
    % aladin needs the rho value for Lxx
    Lxx = @(x, lambda, rho)opf_hessfcn(x, lambda, cost_mult, om, Ybus, Yf(il,:), Yt(il,:), mpopt, il);
end