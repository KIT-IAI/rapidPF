function n = find_slack_gen_entry(mpc)
% find_slack_gen_entry
%
%   `n = find_slack_gen_entry(mpc)`
%
%   _Find the entry `n` in the `gen`-field of the case file `mpc` belonging to the slack bus._
%
%   ## See also
%   - [find_slack_bus](find_slack_bus.md)
%   - [find_generator_gen_entry](find_generator_gen_entry.md)
    [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
        MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
        QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
    n = find(mpc.gen(:, BUS_TYPE) == REF);
end