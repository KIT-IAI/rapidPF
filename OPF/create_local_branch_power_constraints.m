function h = create_local_branch_power_constraints(Vang, Vmag, Fmax, Ybus,from_bus,to_bus)
    Nbus       = numel(Vang);
    Nbranch    = numel(from_bus);
    Vmagk      = repmat(Vmag,1,Nbus);
    [M_p, M_q] = build_pf_matrix(Vang, Ybus);
%     P1         = Vmag.^2.*real(Ybus);
%     P2         = Vmagk'*M_p*Vmagk;
    Pij        =  Vmag.^2.*real(Ybus)- Vmagk'.*M_p.*Vmagk ;
    
    Qij        = -Vmag.^2.*imag(Ybus) - Vmagk'.*M_q.*Vmagk;
    idx_from   = sub2ind([Nbus,Nbus],from_bus,to_bus);
    idx_to     = sub2ind([Nbus,Nbus],to_bus,from_bus);
    pij_from   = Pij(idx_from);
    qij_from   = Qij(idx_from);
    pij_to     = Pij(idx_to);
    qij_to     = Qij(idx_to);
    S_from     = pij_from.^2+qij_from.^2-Fmax.^2;
    S_to       = pij_to.^2+qij_to.^2-Fmax.^2;

%     for i = 1:Nbranch
%         S_from(i)     = sqrt(pij_from(i)^2+qij_from(i)^2)-Fmax;
%         S_to(i)       = sqrt(pij_to(i)^2+qij_to(i)^2)-Fmax;        
%     end
    h          = vertcat(S_from, S_to);
end