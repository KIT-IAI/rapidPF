function f = create_bus_specifications_and_remove_bus_new(Vang, Vmag, Pnet, Qnet, mpc, local_bus_to_remove)
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
    
%     [~, pv, pq] = bustypes(bus, gen);
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
    % exclude generators that are copy buses
%     gbus = intersect(gbus, union(ref, pv));
    
    % slack
    V0  = bus(:, VM) .* exp(1j * pi/180 * bus(:, VA));
    vcb = ones(size(V0));           %% create mask of voltage-controlled buses
    vcb(pq) = 0;                    %% exclude PQ buses
    k = find(vcb(gbus));            %% in-service gens at v-c buses
    V0(gbus(k)) = gen(on(k), VG) ./ abs(V0(gbus(k))).* V0(gbus(k));
    
    
    f_V = [Vang(ref) - angle(V0(ref));  % angle reference
           Vmag(gbus) - abs(V0(gbus))]; % voltage magnitude references
    
    
    Snet = makeSbus(baseMVA, bus, gen, mpopt, Vmag);
    
    f_S = [ real(Snet(pq)) - Pnet(pq);
            imag(Snet(pq)) - Qnet(pq);
            real(Snet(pv)) - Pnet(pv)];
    
    f = [f_V; f_S];
%     has_correct_size(f, 2*(numel(Vang) - numel(bus_to_remove)));
end

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
    %%
    types = get_bus_types(bus, buses);
    
    if unique(types) == 1
        % do nothing
    elseif unique(types) == 2
        % the buses to be removed are generator buses
        gen_entries = find(gen(:, GEN_BUS) == buses);
        gen(gen_entries, :) = [];
    elseif unique(types) == 3
        error('asked to remove the slack. bad idea.')
    else
        error('the buses to be removed are not unique; please double-check.')
    end
end

function types = get_bus_types(bus, buses)
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
        VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
    types = bus(buses, BUS_TYPE);
end

