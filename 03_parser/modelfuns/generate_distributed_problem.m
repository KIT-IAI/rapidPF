function problem = generate_distributed_problem(mpc, names)
    % extract Data from casefile
    [N_regions, N_buses_in_regions, N_copy_buses_in_regions, N_core_buses_in_regions] = get_relevant_information(mpc, names);
    [costs, inequalities, equalities, states, xx0, pfs, bus_specs] = deal(cell(N_regions,1));
    connection_table = mpc.(names.consensus);
    % set up the Ai's
    consensus_matrices = create_consensus_matrices(connection_table, N_buses_in_regions, N_copy_buses_in_regions);
    % create local power flow problems
    fprintf('\n\n');
    for i = 1:N_regions
        fprintf('Creating power flow problem for system %i...', i);
        [cost, inequality, equality, x0, pf, bus_spec, state] = generate_local_power_flow_problem(mpc.(names.split){i}, names, num2str(i));
        [costs{i}, inequalities{i}, equalities{i}, xx0{i}, pfs{i}, bus_specs{i}, states{i}] = deal(cost, inequality, equality, x0, pf, bus_spec, state);
        fprintf('done.\n')
    end
    %% generate output
    problem.locFuns.ffi = costs;
    problem.locFuns.ggi = equalities;
    problem.locFuns.hhi = inequalities;

    problem.zz0 = xx0;
    problem.AA  = consensus_matrices;
    
    problem.pf = pfs;
    problem.bus_specs = bus_specs;
    problem.state = states;
end
    


