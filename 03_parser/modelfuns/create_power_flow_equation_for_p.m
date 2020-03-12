function fun = create_power_flow_equation_for_p(Vang, Vmag, Pnet, Qnet, Y, relevant_buses)
    if nargin == 5
        check_dimension(Vang, Vmag, Pnet, Qnet);        
        relevant_buses = 1:numel(Vang);
    end
    assert(numel(Vang) == numel(Vmag), 'inconsistent dimensions for voltages')
    assert(numel(Pnet) == numel(Qnet), 'inconsistent dimensions for powers');
    
    assert(numel(Pnet) == numel(relevant_buses) && numel(Qnet) == numel(relevant_buses), 'inconsistent dimensions')
    [M_p, ~] = build_pf_matrix(Vang, Y);
    P = Vmag .* (M_p * Vmag);
    fun = P(relevant_buses) - Pnet;
end



