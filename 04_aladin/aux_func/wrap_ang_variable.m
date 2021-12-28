function x = wrap_ang_variable(x,idx_ang)
    % wrap angle variables to [-pi, pi], if they are not in the interval
    % x       - state variable
    % idx_ang - logical array represents entries of angle variable 
    if any((x(idx_ang)<-pi) | (x(idx_ang)>pi))
        x(idx_ang) = wrapToPi(x(idx_ang));
    end
end
