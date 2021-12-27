function fun = create_power_flow_equation_for_q_half(state_var, state_const, Y, relevant_buses, entries)
    % stack the constants and variables to form the whole state
    [Vang, Vmag, Qnet] = stack_const_and_variables_q(state_var, state_const, entries);
    
    % build pf equation for p
    [~, M_q] = build_pf_matrix(Vang, Y);
    Q = Vmag .* (M_q * Vmag);
    
    % get the function
    fun = Q(relevant_buses) - Qnet;
end