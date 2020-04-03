function bus = find_slack_bus(mpc)
% find_slack_bus
%
%   `bus = find_slack_bus(mpc)`
%
%   _Find the bus number `bus` of the slack bus in the case file `mpc`._
%
%   ## See also
%   - [find_slack_gen_entry](find_slack_gen_entry.md)
%   - [find_generator_gen_entry](find_generator_gen_entry.md)
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
            VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
    bus = find(mpc.bus(:, BUS_TYPE) == REF);
end