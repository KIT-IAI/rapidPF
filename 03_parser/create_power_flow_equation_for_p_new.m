function fun = create_power_flow_equation_for_p_new(state_var, state_const, Y, relevant_buses, entries)
    % stack the constants and variables to form the whole state
    [Vang, Vmag, Pnet] = stack_const_and_variables_p(state_var, state_const, entries);
    
    % build pf equation for p
    [M_p, ~] = build_pf_matrix(Vang, Y);
    P = Vmag .* (M_p * Vmag);
    
    % get the function
    fun = P(relevant_buses) - Pnet;
end