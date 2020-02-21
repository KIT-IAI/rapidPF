function [y, y_stacked] = validate_distributed_problem_formulation(problem, mpc, names)
    [y, y_stacked] = extract_results_per_region_with_copies(mpc, names);
    N_regions = numel(y);
    region = (1:N_regions)';

    fprintf('\n\n\n--------------------------------------------');
    fprintf('\nValidating distributed problem formulation\n\n')
    pf_residual = cell2mat(arrayfun(@(i)norm(double(subs(problem.pf{i}, problem.xx{i}, y_stacked{i})),Inf), 1:N_regions, 'UniformOutput', false))';
    bus_residual = cell2mat(arrayfun(@(i)norm(double(subs(problem.bus_specs{i}, problem.xx{i}, y_stacked{i})), Inf), 1:N_regions, 'UniformOutput', false))';
    
    T = table(region, pf_residual, bus_residual)
    
    % check consensus
    con_residual = build_consensus_constraints(problem, y_stacked);
    fprintf('Consensus violation: %e\n', norm(con_residual, Inf))
    
    bus_residual = arrayfun(@(i)double(subs(problem.bus_specs{i}, problem.xx{i}, y_stacked{i})), 1:N_regions, 'UniformOutput', false);
%     bus_residual{:}
    fprintf('--------------------------------------------\n\n\n');
    
end