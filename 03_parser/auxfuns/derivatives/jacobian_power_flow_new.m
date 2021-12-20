function J = jacobian_power_flow_new(state_var, state_0, Ybus, entries, buses_to_ignore)
    import casadi.*
    % get entries of variables   
    [vang_i, n_vang_var] = size(entries.variable.v_ang);
    [vmag_i, n_vmag_var] = size(entries.variable.v_mag);
    [pnet_i, n_pnet_var] = size(entries.variable.p_net);
    [qnet_i, n_qnet_var] = size(entries.variable.q_net);
    
    n_vang_var = n_vang_var * vang_i;
    n_vmag_var = n_vmag_var * vmag_i;
    n_pnet_var = n_pnet_var * pnet_i;
    n_qnet_var = n_qnet_var * qnet_i;
    
    entries_var_vang = (1:n_vang_var);
    entries_var_vmag = (1:n_vmag_var) + n_vang_var;
    entries_var_pnet = (1:n_pnet_var) + n_vang_var + n_vmag_var;
    entries_var_qnet = (1:n_qnet_var) + n_vang_var + n_vmag_var + n_pnet_var;
   
    % get entries of constants
    [vang_i_c, n_vang_c] = size(entries.constant.v_ang);
    [vmag_i_c, n_vmag_c] = size(entries.constant.v_mag);
    [pnet_i_c, n_pnet_c] = size(entries.constant.p_net);
    n_qnet_c = size(entries.constant.q_net);
    
    % if empty, n will be 0 not 1
    n_vang_c = n_vang_c * vang_i_c;
    n_vmag_c = n_vmag_c * vmag_i_c;
    n_pnet_c = n_pnet_c * pnet_i_c;
    
    % create entries for constant
    entries_c_vang = (1:n_vang_c);
    entries_c_vmag = (1:n_vmag_c) + n_vang_c;
    entries_c_pnet = (1:n_pnet_c) + n_vang_c + n_vmag_c;
    entries_c_qnet = (1:n_qnet_c) + n_vang_c + n_vmag_c + n_pnet_c;
    
    % build the whole state
    Va(entries.variable.v_ang) = state_var(entries_var_vang);
    Va(entries.constant.v_ang) = state_0(entries.constant.v_ang_global);
    
    Vm(entries.variable.v_mag) = state_var(entries_var_vmag);
    Vm(entries.constant.v_mag) = state_0(entries.constant.v_mag_global);
    
    P(entries.variable.p_net) = state_var(entries_var_pnet);
    P(entries.constant.p_net) = state_0(entries.constant.p_net_global);
    
    Q(entries.variable.q_net) = state_var(entries_var_qnet);
    Q(entries.constant.q_net) = state_0(entries.constant.q_net_global);
    
    % build the derivative
    if isstruct(Ybus)
        Ybus = makeYbus(Ybus);
    end
    V = Vm .* exp(1j * Va);
    [dS_dVa, dS_dVm] = dSbus_dV(Ybus, V');
    
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