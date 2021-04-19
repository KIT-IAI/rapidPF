function pf_p = create_local_power_flow_equation_p(Vang, Vmag,Pg, Ybus,gen_bus_entries,core_bus_entries,Pd)
    [M_p, ~] = build_pf_matrix(Vang, Ybus);
    P = Vmag .* (M_p * Vmag)+ Pd;
    P = P(core_bus_entries);
    % plus / minus
    
    pf_p   = P ;
    pf_p(gen_bus_entries) = P(gen_bus_entries) - Pg;

%     pf_p(end) = [];
end
