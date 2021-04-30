results_pf = runpf('case3_personalized');
results_opf = runopf('case3_personalized');

[f, df, d2f] = opf_costfcn(results_opf.x, results_opf.om);

mpc   = loadcase('case3_personalized');
names = generate_name_struct();

[mpc_opf, om, local_buses_to_remove, mpopt] = prepare_case_file(mpc, names);





[constraint_function, ~] = build_local_constraint_function(mpc_opf, om, mpopt);
%% cost function + cost gradient
[cost, grad_cost, hess_cost] = build_local_cost_function(om);
%% equalities + Jacobian
eq = @(x)get_eq_cons(x, constraint_function, inds);
eq_jac = @(x)get_eq_cons_jacobian(x, constraint_function, inds);
%% inequalities + Jacobian
[ineq, ineq_jac] = build_local_inequalities(constraint_function);

pf = eq(results_opf.x);
h = ineq(results_opf.x);

%% equalities
function g = get_eq_cons(x, gh_fcn, inds)
    [~,g,~,~] = gh_fcn(x);
    % remove power flow equations for all copy buses
    g(inds) = [];
end

function dg = get_eq_cons_jacobian(x, gh_fcn, inds)
    [~,~,~,dg] = gh_fcn(x);
    dg(:, inds) = [];
end
