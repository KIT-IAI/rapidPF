function [grad, JJp, Hess] = sens_pf_full(Va, Vm, P, Q, r, Ybus, buses_to_ignore, Jac_bus)
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
        
    J = sparse([real(dS_dVa), real(dS_dVm), -speye(ntotal, ncore),   sparse(ntotal, ncore) ;
                imag(dS_dVa), imag(dS_dVm),  sparse(ntotal, ncore), -speye(ntotal, ncore);
                Jac_bus]);
   
    J = remove_rows(J, buses_to_ignore, ntotal);
    
    grad = (r*J)';
    JJp  = @(p)J'*(J*p);
    if nargout >2
        Hess = J'*J;
        JJp  = J;
    end
end