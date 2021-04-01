function J = jacobian_power_flow_modified(Va, Vm, Pg, Qg, Ybus, gen_bus_entries,copy_bus_entries)
    if nargin == 5
        buses_to_ignore = [];
    end
    if isstruct(Ybus)
        Ybus = makeYbus(Ybus);
    end
    V = Vm .* exp(1j * Va);
    [dS_dVa, dS_dVm] = dSbus_dV(Ybus, V);
    
    assert(numel(Va) == numel(Vm));
    assert(numel(Pg) == numel(Qg));
    Ngen = numel(Pg);
    Nx = numel(Va);
    
    
    J_P = [ real(dS_dVa), real(dS_dVm), reshape_col(-speye(Nx, Nx),gen_bus_entries),   sparse(Nx, Ngen) ];
    J_Q = [ imag(dS_dVa), imag(dS_dVm),  sparse(Nx, Ngen), reshape_col(-speye(Nx, Nx),gen_bus_entries) ];
    J = [J_P; J_Q];
    remove_idx = [copy_bus_entries, copy_bus_entries+Nx];
    J = remove_rows_modified(J, remove_idx);
end

function A_modidfied = reshape_col(A, entries)
    A_modidfied = A(:,entries);
end


function A = remove_rows_modified(A, entries)
    A(entries,:)=[];
end