function [vang, vmag, pnet, qnet] = extract_results(mpc)
    [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
        VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
    [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
        MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
        QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
    %% get reference solution
    [baseMVA, bus, gen] = deal(mpc.baseMVA, mpc.bus, mpc.gen);
    Nbus = size(mpc.bus, 1);
    
    mpopt = mpoption;
    [Pdf, Qdf] = total_load(bus, gen, 'bus', struct('type', 'FIXED'), mpopt);
    [vang, vmag, pgen, qgen, pdem, qdem] = deal(zeros(Nbus, 1));
    
    for i = 1:Nbus
        vang(i) = bus(i, VA);
        vmag(i) = bus(i, VM);
        g  = find(gen(:, GEN_STATUS) > 0 & gen(:, GEN_BUS) == bus(i, BUS_I) & ...
                    ~isload(gen));
        if ~isempty(g)
            pgen(i) = sum(gen(g, PG));
            qgen(i) = sum(gen(g, QG));
        end
        ld = find(gen(:, GEN_STATUS) > 0 & gen(:, GEN_BUS) == bus(i, BUS_I) & ...
                    isload(gen));
        if Pdf(i) || Qdf(i) || ~isempty(ld)
            if ~isempty(ld)
                pdem(i) = Pdf(i) - sum(gen(ld, PG));
                qdem(i) = Qdf(i) - sum(gen(ld, QG));
            else
                pdem(i) = Pdf(i);
                qdem(i) = Qdf(i);
            end
        end
    end
    pnet = pgen - pdem;
    qnet = qgen - qdem;
    %% convert back to radians and p.u.
    vang = vang * pi / 180;
    pnet = pnet / baseMVA;
    qnet = qnet / baseMVA;
end