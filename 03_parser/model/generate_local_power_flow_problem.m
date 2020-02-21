function [cost, ineq, eq, state, x0, pf, bus_specifications] = generate_local_power_flow_problem(mpc, names, postfix)
    buses_core = mpc.(names.regions.global);
    N_core = numel(buses_core);
    buses_local = 1:N_core;
%     copy_buses_global = mpc.(names.copy_buses.global);
%     buses = union(buses_core, copy_buses_global);
    copy_buses_local = mpc.(names.copy_buses.local);
    
    N_copy = numel(copy_buses_local);
    Ybus = makeYbus(ext2int(mpc));
    %% problem formulation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% The following code (implicitly) assumes that the copy buses are
    %%% always at the end of the bus numbering.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [Vang_core, Vmag_core, Pnet_core, Qnet_core] = create_state(postfix, N_core);
    [Vang_copy, Vmag_copy, Pnet_copy, Qnet_copy] = create_state(strcat(postfix, '_copy'), N_copy);
    
    Vang = [Vang_core; Vang_copy];
    Vmag = [Vmag_core; Vmag_copy];
    Pnet = Pnet_core;
    Qnet = Qnet_core;
    
    state = stack_state(Vang, Vmag, Pnet, Qnet);
    
    [pf_p, pf_q] = create_power_flow_equations(Vang, Vmag, Pnet, Qnet, Ybus, buses_local);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% There is currently an inconsistency between the set up of the power
    %%% flow equations:
    %%%     'create power flow equations for all nodes stored in
    %%%     buses_local',
    %%% and the bus specifications:
    %%%     'create bus specifications and remove copy buses'.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bus_specifications = create_bus_specifications(Vang_core, Vmag_core, Pnet_core, Qnet_core, mpc, copy_buses_local);
    
    % initial condition for local problem
    [Vang0, Vmag0, Pnet0, Qnet0] = create_initial_condition(mpc, copy_buses_local);
    x0 = stack_state(Vang0, Vmag0, Pnet0, Qnet0);
    
    % verification
%     verify_power_flow_equations(mpc);
%     verify_bus_specifications(mpc);
    
    %% check sizes
    has_correct_size(x0, 4*N_core + 2*N_copy);
    has_correct_size(state, 4*N_core + 2*N_copy);
    has_correct_size(pf_p, N_core);
    has_correct_size(pf_q, N_core);
    has_correct_size(bus_specifications, 2*N_core);
    %% generate return values
    cost = @(x)0*sum(x);
    ineq = @(x)[];
    eq = [ pf_p; pf_q; bus_specifications ];
    pf = [ pf_p; pf_q ];
end
