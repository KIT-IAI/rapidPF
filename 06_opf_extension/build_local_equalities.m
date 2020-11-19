function [eq, eq_jac] = build_local_equalities(constraint_function, local_buses_to_remove)
    eq = @(x)get_eq_cons(x, constraint_function, copy_buses_local);
    eq_jac = @(x)get_eq_cons_jacobian(x, constraint_function);
end

%% equalities
function g = get_eq_cons(x, gh_fcn, local_buses_to_remove)
    [~,g,~,~] = gh_fcn(x);
    % remove power flow equations for all copy buses
    inds = [local_buses_to_remove; 2 * local_buses_to_remove];
    g(inds) = [];
end

function dg = get_eq_cons_jacobian(x, gh_fcn)
    [~,~,~,dg] = gh_fcn(x);
end
