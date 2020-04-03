% check whether the generators is out-of-service, (ref: Manual Table B-2)
function check_out_of_service(mpc)
% INPUT
% mpc -- casefile
    [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
        MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
        QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
    % check whether ALL generators are in-service
    assert(sum(mpc.gen(:, GEN_STATUS) <= 0) == 0, 'post_processing:check_out_of_service', 'Some generator is out of service. Please check.')
end