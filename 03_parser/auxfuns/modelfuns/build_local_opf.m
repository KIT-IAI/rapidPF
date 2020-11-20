function [cost, ineq, eq, x0, grad_cost, eq_jac, ineq_jac, lagrangian_hessian, state, dims, lb, ub] = build_local_opf(mpc, names, postfix)
% build_local_opf
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
    %% preparation
    [mpc_opf, om, local_buses_to_remove, mpopt] = prepare_case_file(mpc, names);
    [constraint_function, ~] = build_local_constraint_function(mpc_opf, om, mpopt);
    %% cost function + cost gradient
    [cost, grad_cost, hess_cost] = build_local_cost_function(om);
    %% equalities + Jacobian
    [eq, eq_jac] = build_local_equalities(constraint_function, local_buses_to_remove);
    %% inequalities + Jacobian
    [ineq, ineq_jac] = build_local_inequalities(constraint_function);
    %% symbolic state
    state = build_local_state(mpc_opf, names, postfix);
    %% hessian of Lagrangian
    [~, ~, lagrangian_hessian] = build_local_lagrangian_function(cost, grad_cost, eq, eq_jac, ineq, ineq_jac);
    %% initial conditions
    x0 = build_local_initial_conditions(om);
    %% lower and upper bounds
    [lb, ub] = build_local_bounds(om);
    %% dimensions of state, equalities, inequalities
    dims = build_local_dimensions(mpc_opf, eq, ineq);
end
