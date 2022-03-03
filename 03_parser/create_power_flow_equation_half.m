function fun = create_power_flow_equation_half(state_var, state_const, Y, relevant_buses, entries)
    % stack the constants and variables to form the whole state
    [Vang, Vmag, Pnet, Qnet] = stack_const_and_variables(state_var, state_const, entries);
    
    % build pf equation for p
    if isnumeric(Vang)
        [M_p, M_q] = build_pf_matrix(Vang, Y);
    else
        [M_p, M_q] = build_pf_matrix_casadi(Vang, Y);
    end
    
    P = Vmag .* (M_p * Vmag);
    Q = Vmag .* (M_q * Vmag);
    
    % get the function
    fun = vertcat(P(relevant_buses) - Pnet,Q(relevant_buses) - Qnet);
end