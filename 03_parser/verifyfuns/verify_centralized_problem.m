function [pf_problem_eval, consensus_eval, x_ref] = verify_centralized_problem(mpc, problem)
    import casadi.*
    Nregions = numel(problem.AA);
    [pf_problem, pf_problem_eval, pf_eval] = deal(cell(Nregions, 1));
    pf_problems_symbolic = problem.ggi;
    state = problem.xx;
    
    res = runpf(mpc);
    [x_ref, x_ref_stacked] = extract_results_per_region(res);
    for i = 1:Nregions
        pf_problem{i} = matlabFunction(pf_problems_symbolic{i}, 'Vars', {state{i}});
        pf_problem_eval{i} = pf_problem{i}(x_ref_stacked{i});
        
        [ang, mag, p, q] = unstack_state(x_ref{i});
        pf_eval{i} = create_power_flow_equations(ang, mag, p, q, mpc.Y{i});
    end    
    
    problem.pf_problem = pf_problem;
    % add consensus constraints
    consensus_eval = build_consensus_constraints(problem, cat(1, x_ref_stacked{:}));
end


