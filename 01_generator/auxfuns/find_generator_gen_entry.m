function gen_entries = find_generator_gen_entry(mpc, bus)
% find_generator_gen_entry
%
%   `gen_entries = find_generator_gen_entry(mpc, bus)`
%
%   _Find all the entries `gen_entries` in the `gen`-field of the case file `mpc` belonging to bus `bus`._
%
%   ## See also
%   - [find_slack_bus](find_slack_bus.md)
%   - [find_slack_gen_entry](find_slack_gen_entry.md)
    [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
        MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
        QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
    gen_entries = find(mpc.gen(:, GEN_BUS) == bus);
end