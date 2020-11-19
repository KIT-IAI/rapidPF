function [cost, grad] = build_local_cost_function(om)
    f = @(x)opf_costfcn(x, om);
    cost = @(x)get_cost(x, f);
    grad = @(x)get_cost_gradient(x, f);
    % hess = @(x)get_cost_hess(x, f);
end

% helper functions
function f = get_cost(x, f_fcn)
    [f,~] = f_fcn(x);
end

function df = get_cost_gradient(x, f_fcn)
    [~, df] = f_fcn(x);
end

% function d2f = get_cost_hess(x, f_fcn)
%     [~,~,d2f] = f_fcn(x);
% end