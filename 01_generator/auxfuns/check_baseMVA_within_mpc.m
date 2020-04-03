% check whether baseMVAs in mpc and in Generators-Data are the same
function check_baseMVA_within_mpc(mpc)
    [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
        MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
        QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
    
    assert(sum(mpc.gen(:, MBASE) ~= mpc.baseMVA) == 0, 'post_processing:baseMVA_inconsistent_within_mpc', 'Inconsistent baseMVA values detected.')
end