function bool = is_generator(mpc, bus)
% is_generator
%
%   `bool = is_generator(mpc, bus)`
%
%   _Check whether `bus` in case file `mpc` is a generator_
    [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
    if  sum(mpc.bus(bus, BUS_TYPE) == PQ) > 0
        % there is an non-generator bus
        bool = false;
    else
        bool = true;
    end
end