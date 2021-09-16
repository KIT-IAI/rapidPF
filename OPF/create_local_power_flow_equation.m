function pf_eq = create_local_power_flow_equation(Vang, Vmag, Pg, Qg, Ybus,Pd,Qd,gen_bus_entries,core_bus_entries)
    [M_p, M_q] = build_pf_matrix(Vang, Ybus);
    P = Vmag .* (M_p * Vmag)+ Pd;
    Q = Vmag .* (M_q * Vmag)+ Qd;
    % remove copy bus
    if nargin>8
    P = P(core_bus_entries);
    Q = Q(core_bus_entries);
    end
    pf_p = P ;
    pf_q = Q ;
    pf_p(gen_bus_entries) = P(gen_bus_entries) - Pg;
    pf_q(gen_bus_entries) = Q(gen_bus_entries) - Qg;
    pf_eq = vertcat(pf_p,pf_q);
%     pf_q(copy_bus_entries) = [];
end