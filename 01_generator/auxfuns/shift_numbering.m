% merge the two case by shifting the bus number in distribution case
function mpc = shift_numbering(mpc, N)
% mpc -- distribution case
% N   -- the number of buses in transmission case
    % matpower built-in naming conventions
    [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;

    [F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, ...
        RATE_C, TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
        ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
    
    %% shift
    mpc.bus(:,BUS_I) = mpc.bus(:,BUS_I) + N;
    mpc.gen(:,BUS_I) = mpc.gen(:,BUS_I) + N;
    mpc.branch(:,F_BUS) = mpc.branch(:,F_BUS) + N;
    mpc.branch(:,T_BUS) = mpc.branch(:,T_BUS) + N;
end