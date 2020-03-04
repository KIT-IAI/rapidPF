function [pf_p, pf_q] = create_power_flow_equations(Vang, Vmag, Pnet, Qnet, Y, relevant_buses)
    if nargin == 5
        check_dimension(Vang, Vmag, Pnet, Qnet);        
        relevant_buses = 1:numel(Vang);
    end

    if numel(Pnet) == numel(relevant_buses) && numel(Qnet) == numel(relevant_buses)
%         V = Vmag .* exp(1j * Vang);
%         S = V .* conj(Y*V);
%         Sreal = real(S);
%         Simag = imag(S);
%         pf_p = Sreal(relevant_buses) - Pnet;
%         pf_q = Simag(relevant_buses) - Qnet;
        

%         pf_p = 0*Vang;
%         pf_q = 0*Vang;
%         
%         Nbus = size(Y, 1);
%         
%         [rows, cols, Yvalues] = find(Y);
%         [rows_sorted, entries] = sort(rows);
%         cols_sorted = cols(entries);
%         Yvalues_sorted = Yvalues(entries);
%         G = real(Yvalues_sorted);
%         B = imag(Yvalues_sorted);
%         counter = 1;
%         
%         for k = 1:Nbus
%             while counter <= numel(rows_sorted) && rows_sorted(counter) == k
%                 m = cols_sorted(counter);
%                 Vang_km = Vang(k) - Vang(m);
%                 pf_p(k) = pf_p(k) + Vmag(k)*Vmag(m)*( G(counter)*cos(Vang_km) + B(counter)*sin(Vang_km) );
%                 pf_q(k) = pf_q(k) + Vmag(k)*Vmag(m)*( G(counter)*sin(Vang_km) - B(counter)*cos(Vang_km) );
%                 counter = counter + 1;
%             end
%         end
%         pf_p = pf_p(relevant_buses) - Pnet;
%         pf_q = pf_q(relevant_buses) - Qnet;

    [M_p, M_q] = build_pf_matrix(Vang, Y);
    P = Vmag .* (M_p * Vmag);
    Q = Vmag .* (M_q * Vmag);
    pf_p = P(relevant_buses) - Pnet;
    pf_q = Q(relevant_buses) - Qnet;

    else
        error('inconsistent dimensions')
    end
end



