function [sol, xsol, xsol_stacked] = solve_distributed_problem_centralized(mpc, problem, names)
    import casadi.*
    Nregions = numel(problem.AA);
    [pf_problem, pf_problem_eval, pf_eval, bus_specs_eval, x_cell] = deal(cell(Nregions, 1));
    pf_problems_symbolic = problem.ggi;
    costs_symbolic = problem.ffi;
    state = problem.xx;
    g = [];
    fsym = 0;

    sizes = cellfun(@(x)numel(x), problem.xx);
    x0 = cat(1, problem.xx0{:});
    %% casadi setup
    x = [];
    for i = 1:Nregions
        x_cell{i} = SX.sym(strcat('x_',num2str(i)), sizes(i));
        pf_problem{i} = matlabFunction(pf_problems_symbolic{i}, 'Vars', {state{i}});
        
        g = [ g; pf_problem{i}(x_cell{i})];
        x = [ x; x_cell{i} ];
        fsym = fsym + costs_symbolic{i}(state{i});
    end    
    cost = matlabFunction(fsym, 'Vars', {cat(1, problem.xx{:})});
    f = cost(x);
    
    problem.pf_problem = pf_problem;
    % add consensus constraints
    g = [g; build_consensus_constraints(problem, x)];
    
    problem.g = g;
    %% build nonlinear program
    nlp = struct('x', x, 'f', f, 'g', g);
    cas = nlpsol('solver', 'ipopt', nlp);
    sol = cas('lbg', zeros(size(g)), 'ubg', zeros(size(g)), 'x0', x0, 'lbx', cat(1, problem.lbx{:}), 'ubx', cat(1, problem.ubx{:}));
    
    %% deal solution back
    [xsol, xsol_stacked] = deal_solution(full(sol.x), mpc, names);
    
    
end


