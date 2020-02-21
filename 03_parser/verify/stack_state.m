% this file specifies the convention for how to stack the state
function x = stack_state(ang, mag, pnet, qnet)
%     check_dimensions(ang, mag, pnet, qnet);
    x = [ang; mag; pnet; qnet];
end

function bool = check_dimensions(ang, mag, pnet, qnet)
    [vals{1:4}] = deal(ang, mag, pnet, qnet);
    numels = cellfun(@(x)numel(x), vals);
    if numel(unique(numels)) == 1
        bool = true;
    else
        bool = false;
        error('inconsistent dimensions for the state vector.');
    end
end