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
    [xsol, xsol_stacked] = deal_solution(sol, mpc, names)
    %% reference solution
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% build a reference solution and copy the values in, then check that
    %%% the power flow equations + bus specifications we constructed are
    %%% valid for them.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     res = runpf(mpc);
%     [x_ref, x_ref_stacked] = extract_results_per_region(res, names);
%     for i = 1:Nregions
%         pf_problem_eval{i} = pf_problem{i}(x_ref_stacked{i});
%         [ang, mag, p, q] = unstack_state(x_ref{i});
%         pf_eval{i} = create_power_flow_equations(ang, mag, p, q, mpc.Y{i});
%         bus_specs_eval{i} = create_bus_specifications(ang, mag, p, q, mpc.split_case_files{i});
%     end
%     consensus_eval = build_consensus_constraints(problem, cat(1, x_ref_stacked{:}));
%     % store solution
%     ref.power_flow = pf_eval;
%     ref.bus_specs = bus_specs_eval;
%     ref.consensus = consensus_eval;
%     ref.sol = x_ref;
%     ref.sol_stacked = x_ref_stacked;

end


