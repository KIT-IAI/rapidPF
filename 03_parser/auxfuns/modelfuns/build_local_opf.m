function [cost, ineq, eq, x0, grad_cost, eq_jac, ineq_jac, lagrangian_hessian, state, dims, lb, ub] = build_local_opf(mpc, names, postfix)
% build_local_opf
%
%   `[cost, ineq, eq, x0, grad_cost, eq_jac, ineq_jac, lagrangian_hessian, state, dims, lb, ub] = build_local_opf(mpc, names, postfix)`
%
%   _extracts the local functions and information needed for opf_
%
%   INPUT: 
%          - $\texttt{mpc}$ splitted full casefile
%          - $\texttt{names}$ struct of names corresponding to the fields
%          of mpc
%          - $\ŧexttt{postfix}$ index of subsystem
%   OUTPUT:
%          - $\texttt{cost}$ scalar local cost function
%          - $\texttt{ineq}$ vector of equality constraint functions
%          - $\texttt{eq}$ vector of inequality constraint functions
%          - $\texttt{x0}$ intial condition of x
%          - $\texttt{grad_cost}$ gradient of cost function
%          - $\texttt{eq_jac}$ jacobian of eqality contraints
%          - $\texttt{ineq_jac}$ jacobian of inequality constraints
%          - $\texttt{lagrangian_hessian}$ hesisan of reduced lagrange
%          function
%          - $\texttt{state}$ representation of objective ariable
%          - $\texttt{dims}$ struct of local dimensions
%          - $\texttt{lb}$ lower bound of x
%          - $\texttt{ub}$ upper bond of x
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The following code (implicitly) assumes that the copy buses are
%%% always at the end of the bus numbering.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    %% preparation
    [mpc_opf, om, local_buses_to_remove, mpopt] = prepare_case_file(mpc, names);
    [constraint_function, Lxx] = build_local_constraint_function(mpc_opf, om, mpopt);
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
    dims = build_local_dimensions(mpc_opf, eq, ineq, local_buses_to_remove);
end
