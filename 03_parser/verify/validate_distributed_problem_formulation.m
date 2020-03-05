function [y, y_stacked] = validate_distributed_problem_formulation(problem, mpc, names)
    [y, y_stacked] = extract_results_per_region_with_copies(mpc, names);
    N_regions = numel(y);
    region = (1:N_regions)';
    %% check equations
    % power flow equations
    pf_residual = cell2mat(arrayfun(@(i)norm(problem.pf{i}(y_stacked{i}), Inf), 1:N_regions, 'UniformOutput', false))';
    % bus specifications
    bus_residual = cell2mat(arrayfun(@(i)norm(problem.bus_specs{i}(y_stacked{i}), Inf), 1:N_regions, 'UniformOutput', false))';
    % consensus
    con_residual = build_consensus_constraints(problem, y_stacked);
    %% show tables
    fprintf('\n\n\n--------------------------------------------');
    fprintf('\nValidating distributed problem formulation\n')
    tab_pf = table(region, pf_residual, bus_residual);
    tab_pf.Properties.VariableNames = {'Region', 'Power flow residuals', 'Bus specification residuals'};
    tab_pf
    
    tab_consensus = table(con_residual);
    tab_consensus.Properties.VariableNames = {'Consensus residuals'};
    tab_consensus
    fprintf('--------------------------------------------\n\n\n');
    
    %% output
    [y, y_stacked] = extract_results_per_region(mpc, names);
end