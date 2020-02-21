% this file specifies the convention for how to stack the state
function [ang, mag, p, q] = unstack_state(x)
    N = numel(x) / 4;
    X = reshape(x, N, 4);
    ang = X(:,1);
    mag = X(:,2);
    p = X(:,3);
    q = X(:,4);
end
