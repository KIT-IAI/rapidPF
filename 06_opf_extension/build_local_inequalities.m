function [ineq, ineq_jac] = build_local_inequalities(constraint_function)
% BUILD_LOCAL_INEQUALITIES
%
%   `[ineq, ineq_jac] = build_local_inequalities(constraint_function, local_buses_to_remove)`
%
%   _extracts all inequalitites from opf_consfcn.m_
%   
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
