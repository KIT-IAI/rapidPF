function aux_entries = get_aux_bus_entries(mpc)
    % find bus_entries of aux nodes in external numbering
    global NAME_FOR_AUX_BUSES_FIELD
    [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
        VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
    
    aux = mpc.(NAME_FOR_AUX_BUSES_FIELD);
    [aux_nodes_check, aux_entries] = intersect(mpc.bus(:, BUS_I), aux);
    check_for_equality(aux, aux_nodes_check);
end

function check_for_equality(x1, x2)
    if sort(x1) ~= sort(x2)
        error('inconsistent lengths for aux_nodes');
    end
end