function [cost, ineq, eq, x0, grad_cost, eq_jac, ineq_jac, lagrangian_hessian, state, dims] = generate_local_power_flow_problem(mpc, names, postfix, problem_type)
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
    Ncore = numel(buses_core);
    copy_buses_local = mpc.(names.copy_buses.local);
    Ncopy = numel(copy_buses_local);
    
    %% preparation
    [mpc_opf, om, local_buses_to_remove, mpopt] = prepare_case_file(mpc, names);
    [constraint_function, lagrangian_hessian] = build_local_constraint_function(mpc_opf, om, mpopt);
    %% cost function + cost gradient
    [cost, grad_cost] = build_local_cost_function(om);
    %% equalities + Jacobian
    [eq, eq_jac] = build_local_equalities(constraint_function, local_buses_to_remove);
    %% inequalities + Jacobian
    [ineq, ineq_jac] = build_local_inequalities(constraint_function);
    %% symbolic state
    state = build_local_state(mpc_opf, names, postfix);
    %% initial conditions
    x0 = rand()
    %% lower and upper bounds
    % [lb, ub] = ...
    
    %% dimensions of state, equalities, inequalities
    dims = build_local_dimensions(mpc_opf, ineq);
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