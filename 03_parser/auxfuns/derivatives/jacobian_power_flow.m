function J = jacobian_power_flow(Va, Vm, P, Q, Ybus, buses_to_ignore)
    if nargin == 5
        buses_to_ignore = [];
    end
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
    
    J = remove_rows(J, buses_to_ignore, ntotal);
end