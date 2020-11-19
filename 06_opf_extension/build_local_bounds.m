function [lb, ub] = build_local_bounds(om)
    [~, lb, ub] = om.params_var();
end