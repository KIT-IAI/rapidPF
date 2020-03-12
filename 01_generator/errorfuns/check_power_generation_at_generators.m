function bool = check_power_generation_at_generators(mpc, gen_entry)
    [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;

    if mpc.gen(gen_entry, PG) ~= 0 || mpc.gen(gen_entry, QG) ~= 0
        bool = true;
        warning('Ignoring generated power for gen entry %i.', gen_entry);
    else
        bool = false;
    end
end