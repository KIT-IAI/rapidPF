function [constraint_function, Lxx] = build_local_constraint_function(mpc_opf, om, mpopt)
    [Ybus, Yf, Yt] = makeYbus(mpc_opf);
    il = find(mpc_opf.branch(:, 6) ~= 0 & mpc_opf.branch(:, 6) < 1e10);
    
    constraint_function = @(x)opf_consfcn(x, om, Ybus, Yf(il,:), Yt(il,:), mpopt, il);
    Lxx = @(x, lambda, cost_mult)opf_hessfcn(x, lambda, cost_mult, om, Ybus, Yf(il,:), Yt(il,:), mpopt, il);
end