function f = create_bus_specifications(Vang, Vmag, Pnet, Qnet, mpc, local_bus_to_remove)
    [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
        VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
    [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
        MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
        QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
    check_dimension(Vang, Vmag, Pnet, Qnet);
    
    if nargin == 5
        local_bus_to_remove = [];
    end
    %%
    mpopt = mpoption;
    mpc = ext2int(mpc, mpopt);
    [baseMVA, bus, gen] = deal(mpc.baseMVA, mpc.bus, mpc.gen);
    
    [ref, pv, pq] = bustypes_ref(bus, gen);
    
    if ~isempty(local_bus_to_remove)
        [ref, pv, pq] = remove_bus(local_bus_to_remove, ref, pv, pq);
        % remove bus entries
        bus_without_copies = remove_bus_entries(bus, local_bus_to_remove);
        % remove gen entries
        gen_without_copies = remove_gen_entries(gen, bus, local_bus_to_remove);
        bus = bus_without_copies;
        gen = gen_without_copies;
    end
    
    on = find(gen(:, GEN_STATUS) > 0);      %% which generators are on?
    gbus = gen(on, GEN_BUS);                %% what buses are they at?
    
    V0ang = bus(:, VA) * pi / 180;
    V0mag = bus(:, VM);
    assert(numel(V0ang) == numel(V0mag), 'inconsistent dimensions');
    
    vcb = ones(size(V0ang));           %% create mask of voltage-controlled buses
    vcb(pq) = 0;                    %% exclude PQ buses
    k = find(vcb(gbus));            %% in-service gens at v-c buses
    
    V0mag(gbus(k)) = gen(on(k), VG) ./ V0mag(gbus(k)) .* V0mag(gbus(k));
    
    f_V = [Vang(ref) - V0ang(ref);  % angle reference
           Vmag(gbus) - V0mag(gbus)]; % voltage magnitude references    
    
    [P, Q] = makeSbus_not_complex(baseMVA, bus, gen, mpopt, Vmag);
    
    f_S = [ P(pq) - Pnet(pq);
            Q(pq) - Qnet(pq);
            P(pv) - Pnet(pv)];
    
    f = [f_V; f_S];
end
%% local functions
function [ref, pv, pq] = remove_bus(bus, ref, pv, pq)
    ref = setdiff(ref, bus);
    pv = setdiff(pv, bus);
    pq = setdiff(pq, bus);
end

function bus = remove_bus_entries(bus, buses)
    bus(buses, :) = [];
end

function gen = remove_gen_entries(gen, bus, buses)
    [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
            MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
            QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
    
    types = get_bus_types(bus, buses);
    if has_slack_entry(types)
        error('asked to remove the slack. bad idea.');
    elseif has_pv_entry(types)
        % there is at least one PV bus, hence remove the corresponding gen
        % entry
        [~, inds] = intersect(gen(:, GEN_BUS), buses);
        gen(inds, :) = [];
    end
end

function bool = has_pv_entry(types)
    [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
        VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
    bool = has_element(types, PV);
end

function bool = has_slack_entry(types)
    [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
        VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
    bool = has_element(types, REF);
end

function bool = has_element(vec, x)
    set = intersect(vec, x);
    if isempty(set)
        bool = false;
    else
        bool = true;
    end
end

function types = get_bus_types(bus, buses)
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
        VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
    types = bus(buses, BUS_TYPE);
end

