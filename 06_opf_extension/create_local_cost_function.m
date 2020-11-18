function f = create_local_cost_function(Vang, Vmag, Pnet, Qnet, mpc, local_bus_to_remove)
% create_local_cost_function
%
%   `copy the declaration of the function in here (leave the ticks unchanged)`
%
%   _describe what the function does in the following line_
%
%   # Markdown formatting is supported
%   Equations are possible to, e.g $a^2 + b^2 = c^2$.
%   So are lists:
%   - item 1
%   - item 2
%   ```matlab
%   function y = square(x)
%       x^2
%   end
%   ```
%   See also: [run_case_file_splitter](run_case_file_splitter.md)
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
    % if isfield(mpc, 'gencost')
    % [baseMVA, bus, gen, gencost] = deal(mpc.baseMVA, mpc.bus, mpc.gen, mpc.gencost);
    % else
    [baseMVA, bus, gen] = deal(mpc.baseMVA, mpc.bus, mpc.gen);
        
    % end
    [ref, pv, pq] = bustypes_ref(bus, gen);
    
    %% build original matpower cost function
    [mpc_opf, mpopt_opf] = opf_args(mpc); % only respect most simple opf formulation so far
    om = opf_setup(mpc_opf, mpopt_opf);
    cost_matpower = @(x_mp)opf_costfcn(x_mp, om);
    
    Cg = build_connection_matrix(bus, gen)
    
    cost = @(x_morenet)cost_matpower(broadcast(x_morenet))
    
    %%
    on_before_removing = find(gen(:, GEN_STATUS) > 0);      %% which generators are on?
    gbus_before_removing = gen(on_before_removing, GEN_BUS);                %% what buses are they at?
    

    
    %%
    
    if ~isempty(local_bus_to_remove)
        [ref, pv, pq] = remove_bus(local_bus_to_remove, ref, pv, pq);
        % remove bus entries
        bus_without_copies = remove_bus_entries(bus, local_bus_to_remove);
        % remove gen entries
        gen_without_copies = remove_gen_entries(gen, bus, local_bus_to_remove);
        % changes for OPF
        if isfield(mpc, 'gencost')
            % remove gen cost entries. ToDo!!!! 
           gencost_without_copies = remove_gen_cost_entries(gen, mpc.gencost, bus, local_bus_to_remove);
        end
        bus = bus_without_copies;
        gen = gen_without_copies;
        gencost = gencost_without_copies;
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
    
    [P, Q] = makeSbus_not_complex(baseMVA, bus, gen, mpopt, Vmag);
    
    gbus = setdiff(gbus, ref);
    assert(isempty(setdiff(pv, gbus)));
    
    if issorted(pv) && issorted(pq)
          % generate bus specifications according to bus types
          f = [ Vang(ref)  - V0ang(ref), Vmag(ref) - V0mag(ref);    % slack
              Pnet(pv) - P(pv), Vmag(gbus) - V0mag(gbus);           % pv buses
              Pnet(pq) - P(pq), Qnet(pq) - Q(pq) ];                 % pq buses
          % re-arrange f such that the ordering is according to the bus numbering
          f = reshape_to_bus_numbering(f, [ref; pv; pq]);
    end
        
end
%% local functions
function f = reshape_to_bus_numbering(f, bus_types)
    [~, sort_to_bus_numbering] = sort(bus_types);
    f = f(sort_to_bus_numbering, :);
    f = reshape(f', 2*numel(bus_types), 1);
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
    
    types = get_bus_types(bus, buses);
    if has_slack_entry(types)
        error('asked to remove the slack. bad idea.');
    elseif has_pv_entry(types)
        % there is at least one PV bus, hence remove the corresponding gen
        % entry
        inds = ismember(gen(:, GEN_BUS), buses);
        gen(inds, :) = [];
    end
end

 function gencost = remove_gen_cost_entries(gen, gencost, bus, buses)
     [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
            MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
            QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
     
    types = get_bus_types(bus, buses);
    if has_pv_entry(types)
        % there is at least one PV bus, hence remove the corresponding
        % gencost entry
        inds = ismember(gen(:, GEN_BUS), buses);
        gencost(inds, :) = [];
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

function x_morenet = broadcast(Vang, Vmag, Pg_mp, Qg_mp, Cg, Pbusd, Qbusd)
    x_morenet = [Vang; Vmag; Cg * Pg_mp - Pbusd; Cg * Qg_mp - Qbusd];
end

