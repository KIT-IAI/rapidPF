function [pf_p, pf_q] = create_power_flow_equations(Vang, Vmag, Pnet, Qnet, Y, relevant_buses)
    if nargin == 5
        check_dimension(Vang, Vmag, Pnet, Qnet);        
        relevant_buses = 1:numel(Vang);
    end

    if numel(Pnet) == numel(relevant_buses) && numel(Qnet) == numel(relevant_buses)
        V = Vmag .* exp(1j * Vang);
        S = V .* conj(Y*V);
        Sreal = real(S);
        Simag = imag(S);
        pf_p = Sreal(relevant_buses) - Pnet;
        pf_q = Simag(relevant_buses) - Qnet;
    else
        error('inconsistent dimensions')
    end
end



