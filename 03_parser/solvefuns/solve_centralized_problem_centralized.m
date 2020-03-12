function [x_sol, x_ref] = solve_centralized_problem_centralized(problem, mpc, names)
    import casadi.*
    state_sym = problem.xx;
    eq_sym = problem.ggi;
    x0 = problem.xx0;
    
    Nx = numel(x0);
    Nbus = Nx / 4;
    %
    x = SX.sym('x', Nx);
    
    eq_fun = matlabFunction(eq_sym, 'Vars', {state_sym});
    
    nlp = struct('x', x, 'f', 0, 'g', eq_fun(x));
    cas = nlpsol('solver', 'ipopt', nlp);
    sol = cas('lbg', zeros(size(eq_sym)), 'ubg', zeros(size(eq_sym)), 'x0', x0);
    
    sol_num = reshape(full(sol.x), Nbus, 4);
    
    % generate output
    sizes = cellfun(@(x)numel(x), mpc.regions);
    Nregions = numel(sizes);
    [x_sol, x_sol_stacked] = deal(cell(Nregions, 1));
    
    N = 0;
    for i = 1:Nregions
        x_sol{i} = sol_num(N + (1:sizes(i)), :);
        x_sol_stacked{i} = stack_state(x_sol{i}(:,1), x_sol{i}(:,2), x_sol{i}(:,3), x_sol{i}(:,4)); 
        N = N + sizes(i);
    end
    
    res = runpf(mpc);
    [x_ref, x_ref_stacked] = extract_results_per_region(res, names);
end