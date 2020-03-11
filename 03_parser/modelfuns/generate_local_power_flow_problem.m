%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The following code (implicitly) assumes that the copy buses are
%%% always at the end of the bus numbering.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% There is currently an inconsistency between the set up of the power
%%% flow equations:
%%%     'create power flow equations for all nodes stored in
%%%     buses_local',
%%% and the bus specifications:
%%%     'create bus specifications and remove copy buses'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cost, ineq, eq, x0, pf, bus_specifications, state] = generate_local_power_flow_problem(mpc, names, postfix)
    buses_core = mpc.(names.regions.global);
    N_core = numel(buses_core);
    buses_local = 1:N_core;
    copy_buses_local = mpc.(names.copy_buses.local);
    N_copy = numel(copy_buses_local);
    Ybus = makeYbus(ext2int(mpc));
    
    [Vang_core, Vmag_core, Pnet_core, Qnet_core] = create_state(postfix, N_core);
    [Vang_copy, Vmag_copy, ~, ~] = create_state(strcat(postfix, '_copy'), N_copy);
    
    Vang = [Vang_core; Vang_copy];
    Vmag = [Vmag_core; Vmag_copy];
    Pnet = Pnet_core;
    Qnet = Qnet_core;
    
    state = stack_state(Vang, Vmag, Pnet, Qnet);
    %% power flow equations
    entries_pf = build_entries(N_core, N_copy, true);
    pf_p = @(x)create_power_flow_equation_for_p(x(entries_pf{1}), x(entries_pf{2}), x(entries_pf{3}), x(entries_pf{4}), Ybus, buses_local);
    pf_q = @(x)create_power_flow_equation_for_q(x(entries_pf{1}), x(entries_pf{2}), x(entries_pf{3}), x(entries_pf{4}), Ybus, buses_local);
    %% bus specifications
    entries_bus_specs = build_entries(N_core, N_copy, false);
    bus_specifications = @(x)create_bus_specifications(x(entries_bus_specs{1}), x(entries_bus_specs{2}), x(entries_bus_specs{3}), x(entries_bus_specs{4}), mpc, copy_buses_local);
    %% initial condition
    [Vang0, Vmag0, Pnet0, Qnet0] = create_initial_condition(mpc, copy_buses_local);
    x0 = stack_state(Vang0, Vmag0, Pnet0, Qnet0);
    %% check sizes
    has_correct_size(x0, 4*N_core + 2*N_copy);
    has_correct_size(pf_p(x0), N_core);
    has_correct_size(pf_q(x0), N_core);
    has_correct_size(bus_specifications(x0), 2*N_core);
    %% generate return values
    cost = @(x)0;
    ineq = @(x)[];
    eq = @(x)[ pf_p(x); pf_q(x); bus_specifications(x) ];
    pf = @(x)[ pf_p(x); pf_q(x) ];
end

function entries = build_entries(N_core, N_copy, with_core)
    if with_core
        N = N_copy;
    else
        N = 0;
    end
        
    entries = cell(4, 1);
    dummy = { 1:N+N_core, 1:N+N_core, 1:N_core, 1:N_core };
    nums = kron([N_core + N_copy; N_core], ones(2, 1));
    nums_cum = [0 ; cumsum(nums)];
    for i = 1:4
        entries{i} = dummy{i} + nums_cum(i);
    end
end