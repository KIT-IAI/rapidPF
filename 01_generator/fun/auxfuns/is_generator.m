% return false when the bus is PQ bus, I.e. pure load without generator
function generator = is_generator(mpc, bus)
% INPUT:
% bus -- bus number for generator check, could be in array
    [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
    if  sum(mpc.bus(bus, BUS_TYPE) == PQ) > 0
        % there is an non-generator bus
        generator = false;
    else
        generator = true;
    end
end