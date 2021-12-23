function [cost, ineq, eq, x0_var, pf, bus_specifications, Jac, grad_cost, Hessian, state_var, dims, entries, state_const] = generate_local_power_flow_problem_new(mpc, names, postfix, problem_type)
% generate_local_power_flow_problem
%
%   `copy the declaration of the function in here (leave the ticks unchanged)`
%
%   _describe what the function does in the following line_
%
%   # Markdown formatting is supported
%   Equations are possible to, e.g $a^2 + b^2 = c^2$.
%   So are lists:
%   - item 1
%   - item 2
%   ```matlab
%   function y = square(x)
%       x^2
%   end
%   ```
%   See also: [run_case_file_splitter](run_case_file_splitter.md)
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
    % get some relevant constant
    buses_core = mpc.(names.regions.global);
    N_core = numel(buses_core);
    buses_local = 1:N_core;
    copy_buses_local = mpc.(names.copy_buses.local);
    N_copy = numel(copy_buses_local);
    Ybus = makeYbus(ext2int(mpc));
    
    % create symbolic expressions
    [Vang_core, Vmag_core, Pnet_core, Qnet_core] = create_state(postfix, N_core);
    [Vang_copy, Vmag_copy, ~, ~] = create_state(strcat(postfix, '_copy'), N_copy);
    
    Vang = [Vang_core; Vang_copy];
    Vmag = [Vmag_core; Vmag_copy];
    Pnet = Pnet_core;
    Qnet = Qnet_core;
     
    % get entries of constants and variables
    entries = build_entries_variable(N_core, N_copy, mpc, copy_buses_local);
    
    % get unknown variables and stack as a vector
    Vang_var = Vang(entries.variable.v_ang);
    Vmag_var = Vmag(entries.variable.v_mag);
    Pnet_var = Pnet(entries.variable.p_net);
    Qnet_var = Qnet(entries.variable.q_net);
    state_var = stack_state(Vang_var, Vmag_var, Pnet_var, Qnet_var);
    %% initial condition
    [Vang0, Vmag0, Pnet0, Qnet0] = create_initial_condition(mpc, copy_buses_local);
    x0 = stack_state(Vang0, Vmag0, Pnet0, Qnet0);
    
    % get initial condition for variables only
    x0_var = x0(entries.variable.stack);
    
    %% get constants
    entries_const = build_entries(N_core, N_copy, false);
    state_const = create_constants(x0(entries_const{1}), x0(entries_const{2}), x0(entries_const{3}), x0(entries_const{4}), mpc, copy_buses_local, entries);
    %% power flow equations
    entries_pf = build_entries(N_core, N_copy, true);
    % new
    pf_p_new = @(x)create_power_flow_equation_for_p_new(x, state_const, Ybus, buses_local, entries);
    pf_q_new = @(x)create_power_flow_equation_for_q_new(x, state_const, Ybus, buses_local, entries);
    pf_p = @(x)create_power_flow_equation_for_p(x(entries_pf{1}), x(entries_pf{2}), x(entries_pf{3}), x(entries_pf{4}), Ybus, buses_local);
    pf_q = @(x)create_power_flow_equation_for_q(x(entries_pf{1}), x(entries_pf{2}), x(entries_pf{3}), x(entries_pf{4}), Ybus, buses_local);
    %% bus specifications
    entries_bus_specs = build_entries(N_core, N_copy, false);
    bus_specifications = @(x)create_bus_specifications(x(entries_bus_specs{1}), x(entries_bus_specs{2}), x(entries_bus_specs{3}), x(entries_bus_specs{4}), mpc, copy_buses_local);
    %% sensitivities
    Jac_pf_new = @(x)jacobian_power_flow_new(x, state_const, Ybus, entries, copy_buses_local);
    Jac_pf  = @(x)jacobian_power_flow(x(entries_pf{1}), x(entries_pf{2}), x(entries_pf{3}), x(entries_pf{4}), Ybus, copy_buses_local);
    Jac_bus = jacobian_bus_specifications(mpc, copy_buses_local);
    Jac_g_ls    = @(x)[Jac_pf(x); Jac_bus];
    % Jac_g_ls = @(x)Jac_pf(x);
    %% check sizes
    has_correct_size(x0, 4*N_core + 2*N_copy);
    has_correct_size(pf_p(x0), N_core);
    has_correct_size(pf_q(x0), N_core);
    has_correct_size(bus_specifications(x0), 2*N_core);
    %% generate return values
    if strcmp(problem_type,'feasibility')
        grad_cost = @(x)zeros(4*N_core + 2*N_copy, 1);
        Hessian = @(x, kappa, rho)jacobian_num(@(y)[Jac_pf(y); Jac_bus]'*kappa, x,  4*N_core + 2*N_copy, 4*N_core+ 2*N_copy);
        cost = @(x) 0;
        ineq = @(x)[];
        eq = @(x)[ pf_p(x); pf_q(x); bus_specifications(x) ];
        pf = @(x)[ pf_p(x); pf_q(x) ];
        Jac = Jac_g_ls;
        dims.eq = 4*N_core;
        dims.ineq = [];
    elseif strcmp(problem_type,'least-squares')
        % g_ls    =  @(x)[pf_p(x); pf_q(x)];
        g_ls    = @(x)[pf_p_new(x); pf_q_new(x)];
        % grad_cost = @(x)(2*Jac_g_ls(x)'* g_ls(x));
        grad_cost = @(x)(2*Jac_pf_new(x)'* g_ls(x));
        % Hessian =  @(x,kappa, rho)(2*Jac_g_ls(x)'*Jac_g_ls(x));%@(x,kappa, rho)(2*Jac_g_ls(x)'*Jac_g_ls(x)); 
        Hessian =  @(x,kappa, rho)(2*Jac_pf_new(x)'*Jac_pf_new(x));
        % cost = @(x)(g_ls(x)'*g_ls(x));
        cost = @(x)(g_ls(x)'*g_ls(x));
        ineq = @(x)[];
        eq = @(x)[];
        % pf = @(x)[ pf_p(x); pf_q(x) ];
        pf = @(x)[pf_p_new(x); pf_q_new(x)];
        Jac = @(x)[];
        dims.eq = [];
        dims.ineq = [];
    end
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