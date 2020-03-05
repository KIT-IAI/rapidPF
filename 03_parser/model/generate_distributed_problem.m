function problem = generate_distributed_problem(mpc, names)
    %% Extract Data from casefile
    N_regions = numel(mpc.(names.regions.global));
    N_buses_in_regions = cellfun(@(x)numel(x), mpc.(names.regions.global_with_copies));
    N_copy_buses_in_regions = cellfun(@(x)numel(x), mpc.(names.copy_buses.global));
    N_core_buses_in_regions = cellfun(@(x)numel(x), mpc.(names.regions.global));
    [costs, inequalities, equalities, states, xx0, pfs, bus_specs] = deal(cell(N_regions,1));
    %% set up the Ai's
    connection_information = get_copy_bus_information(mpc, names);
    consensus_matrices = create_consensus_matrices(connection_information, N_buses_in_regions, N_copy_buses_in_regions);
    %% create local power flow problems
    fprintf('\n\n');
    for i = 1:N_regions
        fprintf('Creating power flow problem for system %i...', i);
        [cost, inequality, equality, x0, pf, bus_spec] = generate_local_power_flow_problem(mpc.(names.split){i}, names);
        [costs{i}, inequalities{i}, equalities{i}, xx0{i}, pfs{i}, bus_specs{i}] = deal(cost, inequality, equality, x0, pf, bus_spec);
        fprintf('done.\n')
    end
    %% ALADIN parameters
    [Sigma, lb, ub] = deal(cell(N_regions,1));
    for i = 1:N_regions
        N_core = N_core_buses_in_regions(i);
        N_copy = N_copy_buses_in_regions(i);
        Sigma{i} = build_Sigma_per_region(N_core, N_copy);
        [lb_temp, ub_temp] = build_bounds_per_region(N_core, N_copy);
        [lb{i}, ub{i}] = deal(lb_temp, ub_temp);
    end
    
    %% generate output
    problem.lbx = lb;
    problem.ubx = ub;
    problem.Sig = Sigma;

    problem.ffi = costs;
    problem.ggi = equalities;
    problem.hhi = inequalities;

    problem.xx  = states;
    problem.xx0 = xx0;
    problem.AA  = consensus_matrices;
    
    problem.pf = pfs;
    problem.bus_specs = bus_specs;
end

function Sigma = build_Sigma_per_region(N_core, N_copy)
    ang = 100;
    mag = 100;
    p = 1;
    q = 1;

    Sigma_core = build_Sigma(N_core, [ang; mag; p; q]);
    Sigma_copy = build_Sigma(N_copy, [ang; mag]);
    Sigma = blkdiag(Sigma_core, Sigma_copy);
end

function Sigma = build_Sigma(Nbus, weights)
    Sigma_diag_entries = kron(weights, ones(Nbus, 1));
    Nw = numel(weights);
    Sigma = speye(Nw*Nbus);
    Sigma(1:1+Nw*Nbus:(Nw*Nbus)^2) = Sigma_diag_entries;
end

function [lb, ub] = build_bounds_per_region(N_core, N_copy)
    ang_lb = -pi/4;
    ang_ub = pi/4;
    mag_lb = 0.5;
    mag_ub = 1.5;
    p_lb = -10;
    p_ub = 10;
    q_lb = -10;
    q_ub = 10;
    
    [lb, ub] = build_bounds(N_core, N_copy, [ang_lb; mag_lb; p_lb; q_lb], [ang_ub; mag_ub; p_ub; q_ub]);
end

function [lb, ub] = build_bounds(Ncore, Ncopy, lb_vec, ub_vec)
    lb = build_bounds_aux(Ncore, Ncopy, lb_vec);
    ub = build_bounds_aux(Ncore, Ncopy, ub_vec);
end

function bounds = build_bounds_aux(Ncore, Ncopy, vec)
    ang = vec(1);
    mag = vec(2);
    p = vec(3);
    q = vec(4);
    
    bounds = [ kron([ang; mag], ones(Ncore + Ncopy, 1));
               kron([p; q], ones(Ncore, 1)) ];
end

