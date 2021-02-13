function [cost, grad, hess] = build_local_cost_function(om)
% BUILD_LOCAL_COST_FUNCTION
%
%    `[mpc_opf, om, copy_buses_local, mpopt] = prepare_case_file(mpc, names))`
%
% INPUT:  - om MATPOWER optimization model
% OUTPUT: - cost function handle for costs
%         - grad function handle for gradient of costs
%         - hess function handle for hessian of cost


    f = @(x)opf_costfcn(x, om);
    cost = @(x)get_cost(x, f);
    grad = @(x)get_cost_gradient(x, f);
    hess = @(x)get_cost_hess(x, f);
end

% helper functions
function f = get_cost(x, f_fcn)
    [f,~,~] = f_fcn(x);
end

function df = get_cost_gradient(x, f_fcn)
    [~, df, ~] = f_fcn(x);
end

function d2f = get_cost_hess(x, f_fcn)
    [~,~,d2f] = f_fcn(x);
end