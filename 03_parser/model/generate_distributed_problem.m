function problem = generate_distributed_problem(mpc, names)
    %% Extract Data from MATPOWER casefile
    N_regions = numel(mpc.(names.regions.global));
    N_buses_in_regions = cellfun(@(x)numel(x), mpc.(names.regions.global_with_copies));
    N_copy_buses_in_regions = cellfun(@(x)numel(x), mpc.(names.copy_buses.global));
    N_core_buses_in_regions = cellfun(@(x)numel(x), mpc.(names.regions.global));
    [costs, inequalities, equalities, states, xx0, pfs, bus_specs] = deal(cell(N_regions,1));
    %% set up the Ai's
    connection_information = get_copy_bus_information(mpc, names);
    AA  =   createAis(connection_information, N_buses_in_regions, N_copy_buses_in_regions);
    %% create local power flow problems
    fprintf('\n\n');
    for i = 1:N_regions
        fprintf('Creating power flow problem for system %i...', i);
        if i == 1
            [cost, inequality, equality, state, x0, pf, bus_spec] = generate_local_power_flow_problem(mpc.(names.split){i}, names, 'trans');
        else
            [cost, inequality, equality, state, x0, pf, bus_spec] = generate_local_power_flow_problem(mpc.(names.split){i}, names, strcat('dist_', num2str(i-1)));
        end
        [costs{i}, inequalities{i}, equalities{i}, states{i}, xx0{i}, pfs{i}, bus_specs{i}] = deal(cost, inequality, equality, state, x0, pf, bus_spec);
        fprintf('done.\n')
    end
    %% ALADIN parameters
%     Sig = build_Sig(N_regions, N_buses_in_regions);
    [lbxc, ubxc] = build_bounds(N_regions, N_core_buses_in_regions, N_copy_buses_in_regions);
    %% generate output
    problem.lbx = lbxc;
    problem.ubx = ubxc;
%     problem.Sig = Sig;

    problem.ffi = costs;
    problem.ggi = equalities;
    problem.hhi = inequalities;

    problem.xx  = states;
    problem.xx0 = xx0;
    problem.AA  = AA;
    
    problem.pf = pfs;
    problem.bus_specs = bus_specs;
end

function Sig = build_Sig(N_regions, N_buses_in_regions)
    Sig = cell(N_regions, 1);
    % penalization values 
    thetap          = 100;
    Vp              = 100;
    Pp              = 1;
    Qp              = 1;

    % set up penalization matrices Sigma
    for i=1:N_regions
        Nbus      = N_buses_in_regions(i);
        weighVec = [    thetap*ones(Nbus,1); Vp*ones(Nbus,1); ...
                        Pp*ones(Nbus,1);     Qp*ones(Nbus,1)];
        % weighting matrices for local lagrangians
        Sig{i}   = diag(weighVec);
    end
end

function [lb, ub] = build_bounds(N_regions, N_core_buses_in_regions, N_copy_buses)
    [lb, ub] = deal(cell(N_regions, 1));
    % lower upper bounds for local opt.
    % (to avoid local minimizers in subsystems)
    lbt             = -pi/4;
    ubt             =  pi/4;
    lbV             =  0.5;%0.9;
    ubV             =  1.5;%1.1;
    lbP             = -10;
    ubP             =  10;
    lbQ             = -10;
    ubQ             =  10;

    for i=1:N_regions
        N_core = N_core_buses_in_regions(i);
        N_copy = N_copy_buses(i);
        lb{i} = [  lbt*ones(N_core + N_copy, 1);
                   lbV*ones(N_core + N_copy, 1);
                   lbP*ones(N_core, 1);
                   lbQ*ones(N_core, 1)];

        ub{i} = [  ubt*ones(N_core + N_copy, 1);
                   ubV*ones(N_core + N_copy, 1);
                   ubP*ones(N_core, 1);
                   ubQ*ones(N_core, 1)];
    end
end

function bool = has_correct_sizes(equalities, states, xx0, mpc, names)
    N_buses_in_regions = cellfun(@(x)numel(x), mpc.(names.regions.global_with_copies));
    N_regions = numel(N_buses_in_regions);
    copy_buses = mpc.(names.copy_buses.local);
    for i = 1:N_regions
        [eq, state, x0, N_bus, copy_bus] = deal(equalities{i}, states{i}, xx0{i}, N_buses_in_regions(i), copy_buses{i});
        
        dim_state = 4*N_bus;
        if i == 1
            % transmission system
            dim_power_flow = 2*N_bus;
            dim_bus_specs = 2*N_bus;
        else
            % distribution system
            dim_power_flow = 2*(N_bus - numel(copy_bus));
            dim_bus_specs = 2*(N_bus - numel(copy_bus));
        end
        
        if numel(x0) ~= dim_state || numel(state) ~= dim_state
            bool = false;
            error('Incorrect state dimension');
        end
        
        if numel(eq) ~= dim_power_flow + dim_bus_specs
            bool = false;
            error('Incorrect equality constraint dimension');
        end
    end
    bool = true;
end



