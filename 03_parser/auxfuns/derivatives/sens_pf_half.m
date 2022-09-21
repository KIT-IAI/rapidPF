function [grad, JJp, Hess] = sens_pf_half(state_var, r, state_0, Ybus, entries, buses_to_ignore)
    % build the whole state
    [Va, Vm, P, Q] = back_to_whole_state(state_var, state_0, entries);
    
    % build the derivative
    if isstruct(Ybus)
        Ybus = sparse(makeYbus(Ybus));
    end
    V = Vm .* exp(1j * Va);
    [dS_dVa, dS_dVm] = dSbus_dV(Ybus, V);
    assert(numel(Va) == numel(Vm));
    assert(numel(P) == numel(Q));
    assert(numel(Va) == numel(buses_to_ignore) + numel(P));
    ncore = numel(P);
    ntotal = numel(Va);
    
%     J_P = [ real(dS_dVa), real(dS_dVm), -speye(ntotal, ncore),   sparse(ntotal, ncore) ];
%     J_Q = [ imag(dS_dVa), imag(dS_dVm),  sparse(ntotal, ncore), -speye(ntotal, ncore) ];
%     J = [J_P; J_Q];
    
    J = sparse([real(dS_dVa), real(dS_dVm), -speye(ntotal, ncore),   sparse(ntotal, ncore) ;
          imag(dS_dVa), imag(dS_dVm),  sparse(ntotal, ncore), -speye(ntotal, ncore) ]);


    % remove rows of copy buses
    J = remove_rows(J, buses_to_ignore, ntotal);
    
    % only get the columns of variables
%     if iscolumn(y)
%         Jx = J(: , entries.variable.stack)*y;
%     elseif isrow(y)
%         Jx = (y*J(: , entries.variable.stack))';
%     elseif isempty(y)
%         Jm = J(: , entries.variable.stack);
%         Jx = Jm'*Jm;
%     end
    Jm   = J(: , entries.variable.stack);
    grad = (r*Jm)';
    JJp  = @(p)Jm'*(Jm*p);
    Nx = numel(grad);
    if nargout >2
        Hess = Jm'*Jm;%+1e-6*speye(Nx);
        JJp  = Jm;
    end
end