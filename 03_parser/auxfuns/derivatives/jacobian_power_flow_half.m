function J = jacobian_power_flow_half(state_var, state_0, Ybus, entries, buses_to_ignore)
    % build the whole state
    [Va, Vm, P, Q] = back_to_whole_state(state_var, state_0, entries);
    
    % build the derivative
    if isstruct(Ybus)
        Ybus = makeYbus(Ybus);
    end
    V = Vm .* exp(1j * Va);
    [dS_dVa, dS_dVm] = dSbus_dV(Ybus, V);
    
    assert(numel(Va) == numel(Vm));
    assert(numel(P) == numel(Q));
    assert(numel(Va) == numel(buses_to_ignore) + numel(P));
    ncore = numel(P);
    ntotal = numel(Va);
    
    J_P = [ real(dS_dVa), real(dS_dVm), -speye(ntotal, ncore),   sparse(ntotal, ncore) ];
    J_Q = [ imag(dS_dVa), imag(dS_dVm),  sparse(ntotal, ncore), -speye(ntotal, ncore) ];
    J = [J_P; J_Q];
    
    % remove rows of copy buses
    J = remove_rows(J, buses_to_ignore, ntotal);
    
    % only get the columns of variables
    J = J(: , entries.variable.stack);
end