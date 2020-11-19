function [ineq, ineq_jac] = build_local_inequalities(constraint_function)
    ineq = @(x)get_ineq_cons(x, constraint_function);
    ineq_jac = @(x)get_ineq_cons_jacobian(x, constraint_function);
end

%% inequalities
function h = get_ineq_cons(x, gh_fcn)
    [h,~,~,~] = gh_fcn(x);
end

function dh = get_ineq_cons_jacobian(x, gh_fcn)
    [~,~,dh,~] = gh_fcn(x);
end
