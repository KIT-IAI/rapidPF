function mpc_split = split_case_file(mpc, N, names)
% split_case_file
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

    NAME_FOR_REGION_FIELD = names.regions.global;
    NAME_FOR_AUX_FIELD = names.regions.global_with_copies;
    NAME_FOR_CONNECTIONS_FIELD = names.connections.global;
    NAME_FOR_AUX_BUSES_FIELD = names.copy_buses.global;
    NAME_FOR_COPY_BUSES_LOCAL = names.copy_buses.local;
    mpc_split.version = mpc.version;
    mpc_split.baseMVA = mpc.baseMVA;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% We need to make sure that the bus number ordering is according to
    %%% the field mpc.connections_with_aux_nodes
    %%% perhaps we do not need the find expressions and a like
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % bus entries
    [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;

    buses = mpc.(NAME_FOR_AUX_FIELD){N};
%     bus_entries = sum(mpc.bus(:, BUS_I) == buses, 2);
%     bus_entry_rows = find(bus_entries == 1);
%     mpc_split.bus = mpc.bus(bus_entry_rows, :);
    
    bus_data = mpc.bus;
    bus_data_split = zeros(numel(buses), size(bus_data, 2));
    for i = 1:numel(buses)
        bus_number = buses(i);
        row = find( bus_data(:, BUS_I) == bus_number);
        bus_data_split(i, :) = bus_data(row, :);
    end
    
    mpc_split.bus = bus_data_split;
    
    % gen entries
    [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
    gen_entries = sum(mpc.gen(:, GEN_BUS) == buses, 2);
    gen_entry_rows = find(gen_entries == 1);
    mpc_split.gen = mpc.gen(gen_entry_rows, :);
    
    % branch entries
    [F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, ...
    RATE_C, TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
    from_entries = sum(mpc.branch(:, F_BUS) == buses, 2);
    to_entries = sum(mpc.branch(:, T_BUS) == buses, 2);
    branch_entry_rows = find(from_entries.*to_entries == 1);
    mpc_split.branch = mpc.branch(branch_entry_rows, :);
    
    mpc_split.(NAME_FOR_REGION_FIELD) = mpc.(NAME_FOR_REGION_FIELD){N};
%     mpc_split.(NAME_FOR_CONNECTIONS_FIELD) = mpc.(NAME_FOR_CONNECTIONS_FIELD){N};
    mpc_split.(NAME_FOR_AUX_FIELD) = mpc.(NAME_FOR_AUX_FIELD){N};
    mpc_split.(NAME_FOR_AUX_BUSES_FIELD) = mpc.(NAME_FOR_AUX_BUSES_FIELD){N};
    mpc_split.(NAME_FOR_COPY_BUSES_LOCAL) = mpc.(NAME_FOR_COPY_BUSES_LOCAL){N};
    
    
    % gencost entries
    [MODEL, STARTUP, SHUTDOWN, NCOST, COST] = idx_cost;
    gen_cost_entries = sum(mpc.gen(:, GEN_BUS) == buses, 2);
    gen_cost_entry_rows = find(gen_entries == 1);
    mpc_split.gencost = mpc.gencost(gen_cost_entry_rows, :);
    if isfield(mpc, 'gencost')
        warning('There is a gencost field. OPF probems are still in beta development mode. Handle with care')
    end
end