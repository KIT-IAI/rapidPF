function fun = create_power_flow_equation_for_p_new(state_var, state_0, Y, relevant_buses, entries, state)
    % get entries of variables
    [vang_i_var, n_vang_var] = size(entries.variable.v_ang);
    [vmag_i_var, n_vmag_var] = size(entries.variable.v_mag);
    [pnet_i_var, n_pnet_var] = size(entries.variable.p_net);
    % [qnet_i, n_qnet_var] = size(entries.variable.q_net);
    
    % if empty, n will be 0 not 1
    n_vang_var = n_vang_var * vang_i_var;
    n_vmag_var = n_vmag_var * vmag_i_var;
    n_pnet_var = n_pnet_var * pnet_i_var;
    % n_qnet_var = n_qnet_var * qnet_i;
    
    % create entries for variables
    entries_var_vang = (1:n_vang_var);
    entries_var_vmag = (1:n_vmag_var) + n_vang_var;
    entries_var_pnet = (1:n_pnet_var) + n_vang_var + n_vmag_var;
    % entries_var_qnet = (1:n_qnet_var) + n_vang_var + n_vmag_var + n_pnet_var;
    
    % get entries of constants
    % [vang_i_c, n_vang_c] = size(entries.constant.v_ang);
    % [vmag_i_c, n_vmag_c] = size(entries.constant.v_mag);
    % [pnet_i_c, n_pnet_c] = size(entries.constant.p_net);
    % n_qnet_c = size(entries.constant.q_net);
    
    % if empty, n will be 0 not 1
    % n_vang_c = n_vang_c * vang_i_c;
    % n_vmag_c = n_vmag_c * vmag_i_c;
    % n_pnet_c = n_pnet_c * pnet_i_c;
    
    % create entries for constant
    % entries_c_vang = (1:n_vang_c);
    % entries_c_vmag = (1:n_vmag_c) + n_vang_c;
    % entries_c_pnet = (1:n_pnet_c) + n_vang_c + n_vmag_c;
    % entries_c_qnet = (1:n_qnet_c) + n_vang_c + n_vmag_c + n_pnet_c;
    
    %Vang = state(entries.v_ang);
   % Vmag = state(entries.v_mag);
    %Pnet = state(entries.p_net);
    % Qnet = sym(strcat('Q_', postfix, '_'), [N 1], 'real');
    
%     [~, n_vang] = size(entries.v_ang);
%     [~, n_vmag] = size(entries.v_mag);
%     [~, n_pnet] = size(entries.p_net);
%     Vang = SX.sym('vand', n_vang);
%     Vmag = SX.sym('xmag', n_vmag);
%     Pnet = SX.sym('pnet', n_pnet);
    
    % build the whole state
%     Vang(entries.variable.v_ang) = state_var(entries_var_vang);
%     Vang(entries.constant.v_ang) = state_0(entries_c_vang);
%     
%     Vmag(entries.variable.v_mag) = state_var(entries_var_vmag);
%     Vmag(entries.constant.v_mag) = state_0(entries_c_vmag);
%     
%     Pnet(entries.variable.p_net) = state_var(entries_var_pnet);
%     Pnet(entries.constant.p_net) = state_0(entries_c_pnet);
    
    % stack the constants and variables to form the whole state
    Vang = [state_var(entries_var_vang); state_0(entries.constant.v_ang_global)];
    Vmag = [state_var(entries_var_vmag); state_0(entries.constant.v_mag_global)];
    Pnet = [state_var(entries_var_pnet); state_0(entries.constant.p_net_global)];
    
    % get the correct order 
    [~, v_ang_order] = sort([entries.variable.v_ang entries.constant.v_ang]);
    [~, v_mag_order] = sort([entries.variable.v_mag entries.constant.v_mag]);
    [~, p_net_order] = sort([entries.variable.p_net entries.constant.p_net]);
    
    Vang = Vang(v_ang_order);
    Vmag = Vmag(v_mag_order);
    Pnet = Pnet(p_net_order);
    
    % build pf equation for p
    [M_p, ~] = build_pf_matrix(Vang, Y);
    P = Vmag .* (M_p * Vmag);
    
    % get the function
    fun = P(relevant_buses) - Pnet;
end