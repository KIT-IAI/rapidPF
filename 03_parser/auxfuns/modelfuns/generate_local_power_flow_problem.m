function [cost, ineq, eq, x0_var, pf, Jac, grad_cost, Hessian, state_var, dims, entries, state_const, g_ls, bus_specifications] = generate_local_power_flow_problem(mpc, names, postfix, problem_type, state_dimension)
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
    N_state = 4 * N_core + 2 * N_copy;
        
    %% get entries of constants and variables
    entries = build_entries_for_problem(N_core, N_copy, mpc, copy_buses_local, state_dimension);
    
    % create symbolic expressions
    [Vang_core, Vmag_core, Pnet_core, Qnet_core] = create_state(postfix, N_core);
    [Vang_copy, Vmag_copy, ~, ~] = create_state(strcat(postfix, '_copy'), N_copy);
    
    Vang = [Vang_core; Vang_copy];
    Vmag = [Vmag_core; Vmag_copy];
    Pnet = Pnet_core;
    Qnet = Qnet_core;
    
    % initial condition
    [Vang0, Vmag0, Pnet0, Qnet0] = create_initial_condition(mpc, copy_buses_local);
    x0 = stack_state(Vang0, Vmag0, Pnet0, Qnet0);
    
    if strcmp(state_dimension,'full')  % use all the state as variables
        %% create symbolic expressions
        state_var = stack_state(Vang, Vmag, Pnet, Qnet);
        %% initial condition
        x0_var = x0;
        %% power flow equations
        pf_eq = @(x)create_power_flow_equation(x(entries.pf{1}), x(entries.pf{2}), x(entries.pf{3}), x(entries.pf{4}), Ybus, buses_local);
%         pf_p = @(x)create_power_flow_equation_for_p(x(entries.pf{1}), x(entries.pf{2}), x(entries.pf{3}), x(entries.pf{4}), Ybus, buses_local);
%         pf_q = @(x)create_power_flow_equation_for_q(x(entries.pf{1}), x(entries.pf{2}), x(entries.pf{3}), x(entries.pf{4}), Ybus, buses_local);
        %% bus specifications
        bus_specifications = @(x)create_bus_specifications(x(entries.const{1}), x(entries.const{2}), x(entries.const{3}), x(entries.const{4}), mpc, copy_buses_local);
        %% sensitivities
        Jac_pf  = @(x)jacobian_power_flow(x(entries.pf{1}), x(entries.pf{2}), x(entries.pf{3}), x(entries.pf{4}), Ybus, copy_buses_local);
        Jac_bus = jacobian_bus_specifications(mpc, copy_buses_local);
        % state const
        state_const = []; % no need
    elseif strcmp(state_dimension,'half')  % use half of the state as variables
        %% create symbolic expressions
        % get unknown variables and stack as a vector
%         Vang_var = Vang(entries.variable.v_ang);
%         Vmag_var = Vmag(entries.variable.v_mag);
%         Pnet_var = Pnet(entries.variable.p_net);
%         Qnet_var = Qnet(entries.variable.q_net);
        state_var = stack_state(Vang(entries.variable.v_ang), Vmag(entries.variable.v_mag), Pnet(entries.variable.p_net), Qnet(entries.variable.q_net));
        %% initial condition
        x0_var = x0(entries.variable.stack);
        %% get constants
        state_const = create_constants(x0(entries.const{3}), mpc, copy_buses_local, entries, N_state);
        %% power flow equations
%         pf_p = @(x)create_power_flow_equation_for_p_half(x, state_const, Ybus, buses_local, entries);
%         pf_q = @(x)create_power_flow_equation_for_q_half(x, state_const, Ybus, buses_local, entries);
        pf_eq = @(x)create_power_flow_equation_half(x, state_const, Ybus, buses_local, entries);
        %% sensitivities
        Jac_x_y = @(x,y)jacobian_power_flow_half(x, y, state_const, Ybus, entries, copy_buses_local);
    end
  
    %% check sizes
    has_correct_size(x0, 4*N_core + 2*N_copy);
%     has_correct_size(pf_p(x0), N_core);
%     has_correct_size(pf_q(x0), N_core);
    
    if strcmp(state_dimension,'full')  % use all the state as variables
        has_correct_size(bus_specifications(x0), 2*N_core);
    end
    
    %% generate return values
    if strcmp(problem_type,'feasibility')
        grad_cost = @(x)zeros(4*N_core + 2*N_copy, 1);
        Hessian = @(x, kappa, rho)jacobian_num(@(y)[Jac_pf(y); Jac_bus]'*kappa, x,  4*N_core + 2*N_copy, 4*N_core+ 2*N_copy);
        cost = @(x) 0;
        ineq = @(x)[];
        eq = @(x)[ pf_eq(x); bus_specifications(x) ];
        pf = @(x)[ pf_eq(x) ];
        Jac = Jac_g_ls;
        dims.eq = 4*N_core;
        dims.ineq = [];
    elseif strcmp(problem_type,'least-squares')
        g_ls    =  @(x)pf_eq(x);
        if strcmp(state_dimension,'full')  % use all the state as variables 
            g_ls = @(x)[pf_eq(x); bus_specifications(x)];
            Jac_g_ls = @(x)[Jac_pf(x); Jac_bus];
            grad_cost = @(x)(Jac_g_ls(x)'* g_ls(x));
            Hessian =  @(x,kappa, rho)(Jac_g_ls(x)'*Jac_g_ls(x));%@(x,kappa, rho)(2*Jac_g_ls(x)'*Jac_g_ls(x)); 
        elseif strcmp(state_dimension,'half')  % use half of the state as variables 
            grad_cost = @(x)Jac_x_y(x,  g_ls(x)');
            Hessian =  @(x,kappa, rho)(Jac_x_y(x,[]));%@(x,kappa, rho)(2*Jac_g_ls(x)'*Jac_g_ls(x)); 
        end
        cost = @(x)(g_ls(x)'*g_ls(x))/2;
        ineq = @(x)[];
        eq = @(x)[];
        pf = @(x) pf_eq(x) ;
        Jac = @(x)[];
        dims.eq = [];
        dims.ineq = [];
    end
end