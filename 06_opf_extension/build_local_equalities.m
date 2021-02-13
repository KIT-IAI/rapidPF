function [eq, eq_jac] = build_local_equalities(constraint_function, local_buses_to_remove)
% BUILD_LOCAL_EQUALITIES
%
%   `[eq, eq_jac] = build_local_equalities(constraint_function, local_buses_to_remove)`
%
%   _extracts the relevant power flow equation for the core buses. Power flow equations of the copy buses are removed_
%   
    inds = [local_buses_to_remove; 2 * local_buses_to_remove];
    eq = @(x)get_eq_cons(x, constraint_function, inds);
    eq_jac = @(x)get_eq_cons_jacobian(x, constraint_function, inds);
end

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
