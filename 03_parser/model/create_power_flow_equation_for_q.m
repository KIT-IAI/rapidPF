function fun = create_power_flow_equation_for_q(Vang, Vmag, Pnet, Qnet, Y, relevant_buses)
    if nargin == 5
        check_dimension(Vang, Vmag, Pnet, Qnet);        
        relevant_buses = 1:numel(Vang);
    end

    assert(numel(Pnet) == numel(relevant_buses) && numel(Qnet) == numel(relevant_buses), 'inconsistent dimensions')
    [M_p, M_q] = build_pf_matrix(Vang, Y);
    Q = Vmag .* (M_q * Vmag);
    fun = Q(relevant_buses) - Qnet;
end



