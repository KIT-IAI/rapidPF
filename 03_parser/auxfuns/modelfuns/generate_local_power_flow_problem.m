function [cost, ineq, eq, x0, grad_cost, eq_jac, ineq_jac, Hessian, state, dims] = generate_local_power_flow_problem(mpc, names, postfix, problem_type)
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
    buses_core = mpc.(names.regions.global);
    N_core = numel(buses_core);
    copy_buses_local = mpc.(names.copy_buses.local);
    N_copy = numel(copy_buses_local);
    
    [Vang_core, Vmag_core, Pnet_core, Qnet_core] = create_state(postfix, N_core);
    [Vang_copy, Vmag_copy, Pnet_copy, Qnet_copy] = create_state(strcat(postfix, '_copy'), N_copy);
    
    Vang = [Vang_core; Vang_copy];
    Vmag = [Vmag_core; Vmag_copy];
    Pnet = Pnet_core;
    Qnet = Qnet_core;
    
    state = stack_state(Vang, Vmag, Pnet, Qnet);
   %% optimal power flow cost + gradient + hessian
   [cost, grad_cost, hess_cost, eq, eq_jac, ineq, ineq_jac] = build_local_cost_function(mpc, names);
    
    %% initial conditions
    % x0 = ...
    %% lower and upper bounds
    % [lb, ub] = ...
    %% generate return values
    if strcmp(problem_type,'feasibility')
        cost = @(x) opf_p(x);
        grad_cost = @(x)gradient_costs(x);
        % grad_cost = @(x) zeros(4*N_core + 2*N_copy, 1);
        % TODO modify for OPF -> add second derivative of f
        Hessian = @(x, kappa, rho)jacobian_num(@(y)[Jac_pf(y); Jac_bus]'*kappa, x,  4*N_core + 2*N_copy, 4*N_core+ 2*N_copy);
        % cost = @(x) opf_p(x);
        ineq = @(x) [];
        eq = @(x)[ pf_p(x); pf_q(x); bus_specifications(x) ];
        pf = @(x)[ pf_p(x); pf_q(x) ];
        % TODO modify to gradient of cost (and later of h)
        Jac = Jac_g_ls;
        dims.eq = 4*N_core;
        dims.ineq = []; 
       % dims.ineq = length(mpc.gencost(:, 1));
    elseif strcmp(problem_type,'least-squares')
        g_ls    =  @(x)[pf_p(x); pf_q(x); bus_specifications(x)];
        grad_cost = @(x)(2*Jac_g_ls(x)'* g_ls(x));
        Hessian =  @(x,kappa, rho)(2*Jac_g_ls(x)'*Jac_g_ls(x));%@(x,kappa, rho)(2*Jac_g_ls(x)'*Jac_g_ls(x)); %@(x, kappa, rho)jacobian_num(@(y)(grad_cost(y)), x, 4*N_core + 2*N_copy, 4*N_core + 2*N_copy);
        cost = @(x)(g_ls(x)'*g_ls(x));
        ineq = @(x)[];
        eq = @(x)[];
        pf = @(x)[ pf_p(x); pf_q(x) ];
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