% find the reference bus/generator in the casefile
function bus = find_slack_bus(mpc)
    [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
            VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
    bus = find(mpc.bus(:, BUS_TYPE) == REF);
end