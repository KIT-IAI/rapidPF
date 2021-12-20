function fun = create_power_flow_equation_for_q_new(state_var, state_0, Y, relevant_buses, entries)
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
    % entries_var_pnet = (1:n_pnet_var) + n_vang_var + n_vmag_var;
    entries_var_qnet = (1:n_qnet_var) + n_vang_var + n_vmag_var + n_pnet_var;
    
    % get entries of constants
    %[vang_i_c, n_vang_c] = size(entries.constant.v_ang);
    %[vmag_i_c, n_vmag_c] = size(entries.constant.v_mag);
    %[~, n_pnet_c] = size(entries.constant.p_net);
    %[qnet_i_c, n_qnet_c] = size(entries.constant.q_net);
    
    % if empty, n will be 0 not 1
    %n_vang_c = n_vang_c * vang_i_c;
    %n_vmag_c = n_vmag_c * vmag_i_c;
    %n_qnet_c = n_qnet_c * qnet_i_c;
    
    % create entries for constant
    %entries_c_vang = (1:n_vang_c);
    %entries_c_vmag = (1:n_vmag_c) + n_vang_c;
    % entries_c_pnet = (1:n_pnet_c) + n_vang_c + n_vmag_c;
    %entries_c_qnet = (1:n_qnet_c) + n_vang_c + n_vmag_c + n_pnet_c;
    
%     [~, n_vang] = size(entries.v_ang);
%     [~, n_vmag] = size(entries.v_mag);
%     % [~, n_pnet] = size(entries.p_net);
%     [~, n_qnet] = size(entries.q_net);
%     Vang = SX.sym('vand', n_vang);
%     Vmag = SX.sym('xmag', n_vmag);
%     Qnet = SX.sym('qnet', n_qnet);
    
    % build the whole state
%     Vang(entries.variable.v_ang) = state_var(entries_var_vang);
%     Vang(entries.constant.v_ang) = state_0(entries_c_vang);
%     
%     Vmag(entries.variable.v_mag) = state_var(entries_var_vmag);
%     Vmag(entries.constant.v_mag) = state_0(entries_c_vmag);
%     
%     Qnet(entries.variable.q_net) = state_var(entries_var_qnet);
%     Qnet(entries.constant.q_net) = state_0(entries_c_qnet);

    % stack the constants and variables to form the whole state
    Vang = [state_var(entries_var_vang); state_0(entries.constant.v_ang_global)];
    Vmag = [state_var(entries_var_vmag); state_0(entries.constant.v_mag_global)];
    Qnet = [state_var(entries_var_qnet); state_0(entries.constant.q_net_global)];
    
    % get the correct order 
    [~, v_ang_order] = sort([entries.variable.v_ang entries.constant.v_ang]);
    [~, v_mag_order] = sort([entries.variable.v_mag entries.constant.v_mag]);
    [~, q_net_order] = sort([entries.variable.q_net entries.constant.q_net]);
    
    Vang = Vang(v_ang_order);
    Vmag = Vmag(v_mag_order);
    Qnet = Qnet(q_net_order);
    
    % build pf equation for p
    [~, M_q] = build_pf_matrix(Vang, Y);
    Q = Vmag .* (M_q * Vmag);
    
    % get the function
    fun = Q(relevant_buses) - Qnet;
end