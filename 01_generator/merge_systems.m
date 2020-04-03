function mpc = merge_systems(mpc_master, mpc_slave, pars, names)
% merge_systems
%
%   `mpc = merge_systems(mpc_master, mpc_slave, pars, names)`
%
%   _Merge the master system and the slave system to another case file `mpc`_
%
%   The physical information about the connecting transformer is stored in `pars`.
    NAME_FOR_CONNECTIONS_FIELD = names.connections.global;
    NAME_FOR_CONNECTIONS_GLOBAL_FIELD = names.connections.local;
    
    trafo_master_bus = pars.transformer.transmission_bus;
    trafo_slave_bus = pars.transformer.distribution_bus;
    params = pars.transformer.params;
    fields_to_merge = pars.fields_to_merge;
    Nbus_trans = get_number_of_buses(mpc_master);       % number of buses in transmission casefile
    Nconn = numel(trafo_master_bus);
    
    %% attain the information of distribution before processing    
    params_slave.Nbus         = get_number_of_buses(mpc_slave);
    params_slave.Nbranch      = get_number_of_branches(mpc_slave);
    params_slave.Ngen         = get_number_of_generators(mpc_slave);   %
    params_slave.Ngen_trafo_bus = zeros(Nconn, 1);
    for k = 1:Nconn
        params_slave.Ngen_trafo_bus(k) = get_number_of_connected_generators(mpc_slave, trafo_slave_bus(k));
    end
    params_slave.Nconn        = Nconn;
    %% pre-processing: run several sanity checks
    pre_processing(mpc_master, mpc_slave, trafo_master_bus, trafo_slave_bus, fields_to_merge);
    %% main part
    mpc_slave = replace_slack_and_generators(mpc_slave, trafo_slave_bus);
    mpc = merge_numbering_and_stack(mpc_master, mpc_slave, fields_to_merge);
    mpc = add_region_information(mpc, Nbus_trans, params_slave.Nbus, names);
    mpc = add_edge_information(mpc, trafo_master_bus, trafo_slave_bus, NAME_FOR_CONNECTIONS_GLOBAL_FIELD);

    trafo_from_bus = trafo_master_bus;
    trafo_to_bus   = trafo_slave_bus + Nbus_trans;
    mpc = add_transformer_branch(mpc, trafo_from_bus, trafo_to_bus, params);
    mpc = add_edge_information(mpc, trafo_from_bus, trafo_to_bus, NAME_FOR_CONNECTIONS_FIELD);
    %% post-processing: run several sanity checks
    post_processing(mpc_master, mpc, params_slave, names);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% carry out sanity check before processing, carried out iteratively
function pre_processing(mpc_master, mpc_slave, master_connection_buses, slave_connection_buses, field_name)
% INPUT
% mpc_trans            -- case file for trans, in 'struct'
% mpc_dist             -- case file for dist,  in 'struct'
% trans_connection_buses -- buses connected to trasfo in transmission
% dist_connection_buses  -- buses connected to trasfo in distribution
    pre_processing_mpc(mpc_master, master_connection_buses, 'transmission', field_name);    
    pre_processing_mpc(mpc_slave, slave_connection_buses, 'distribution', field_name);
    check_baseMVA_between_mpc(mpc_master, mpc_slave);    
end

function pre_processing_mpc(mpc, buses, msg, field_name)
    check_out_of_service(mpc);
    check_connection(mpc, buses, msg);
    check_baseMVA_within_mpc(mpc);
    for i = 1:numel(field_name)
        check_existence_of_field(mpc, field_name{i});
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check the number of buses, branches and generators in mpc_merge
% check the working state of the merged case-file
function post_processing(mpc_master, mpc_merge, params_slave, names)
% INPUT
% mpc_trans   -- case-file for transmission
% mpc_merge   -- combined case-file after merging
% params_dist -- parameters of distribution before the processing
    NAME_FOR_CONNECTIONS_FIELD = names.connections.global;
    % transmission
    Nbus_master    =  get_number_of_buses(mpc_master);       % number of buses in transmission casefile
    Nbranch_master =  get_number_of_branches(mpc_master);    % .......... branch ...
    Ngen_master    =  get_number_of_generators(mpc_master);  % ...........generators ...
    % distribution
    Nbus_slave = params_slave.Nbus;    
    Nbranch_slave = params_slave.Nbranch; 
    Ngen_slave = params_slave.Ngen;    
    Ngen_trafo_slave_bus = params_slave.Ngen_trafo_bus;
    % connections
    Nbranch_conn  =  params_slave.Nconn;

    % combined model
    Ngen_mpc      =  get_number_of_generators(mpc_merge);

    check_number_of_buses(Nbus_master,Nbus_slave,mpc_merge)
    check_number_of_branches(Nbranch_master, Nbranch_slave, Nbranch_conn, mpc_merge)
    check_number_of_generators(Ngen_master, Ngen_slave, Ngen_trafo_slave_bus, Ngen_mpc);
    
    edges = mpc_merge.(NAME_FOR_CONNECTIONS_FIELD){end};
    from_edges = edges(:, 1);
    to_edges = edges(:, 2);
    for i = 1:numel(from_edges)
        check_for_line(mpc_merge, from_edges(i), to_edges(i));
    end

    check_out_of_service(mpc_merge);
    check_baseMVA_within_mpc(mpc_merge);        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mpc = add_edge_information(mpc, from_bus, to_bus, field_name)
    N = length(mpc.(field_name));
    mpc.(field_name){N + 1} = [from_bus, to_bus];
end

function mpc_master = merge_numbering_and_stack(mpc_master, mpc_slave, fields_to_merge)
    N_master = get_number_of_buses(mpc_master);
    mpc_slave = shift_numbering(mpc_slave, N_master);
    
    % stack fields from master system and slave system
    for i=1:numel(fields_to_merge)
        field_name = char(fields_to_merge(i));
        mpc_master.(field_name) = [ mpc_master.(field_name); mpc_slave.(field_name)  ];
    end
end

function mpc = add_transformer_branch(mpc, from_buses, to_buses, pars)
    assert(numel(from_buses) == numel(to_buses), 'inconsistent dimensions');
    for i = 1:numel(from_buses)
        from_bus = from_buses(i);
        to_bus = to_buses(i);
        par = pars{i};
        assert(from_bus < to_bus, 'Per convention, the transformer connects TRANSMISSION to DISTRIBUTION, where TRANSMISSION bus numbers must be lower than DISTRIBUTION bus numbers.');
        branch_entry = generate_branch_entry(from_bus, to_bus, par.r, par.x, par.b, par.ratio, par.angle);
        mpc.branch = [mpc.branch; branch_entry];
    end
end

function entry = generate_branch_entry(from_bus, to_bus, r, x, b, ratio, angle)
    [F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, ...
        RATE_C, TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
        ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
    
    entry = zeros(1,13);
    entry(F_BUS) = from_bus;
    entry(T_BUS) = to_bus;
    entry(BR_R) = r;
    entry(BR_X) = x;
    entry(BR_B) = b;
    entry(TAP) = ratio;
    entry(SHIFT) = angle;
    entry(BR_STATUS) = 1;
end

function mpc = add_region_information(mpc, N_currently, N_to_add, names)
    NAME_FOR_REGION_FIELD = names.regions.global;
    NAME_FOR_REGION_LOCAL_FIELD = names.regions.local;
    
    N_regions = length(mpc.(NAME_FOR_REGION_FIELD));
    mpc.(NAME_FOR_REGION_FIELD){N_regions + 1} = (1:N_to_add) + N_currently;
    mpc.(NAME_FOR_REGION_LOCAL_FIELD){N_regions + 1} = 1:N_to_add;
end

function mpc = replace_generator(mpc, bus, replace_by)
    % using index instead of number
    [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
        VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus; 
    
    [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
    % check bus type is either PG or PV
    check_bus_type(replace_by);   % original bus type
    
    if nargin == 3
        msg = 'generator';
    end

    % get indices for the selected generators in GEN_DATA
    gen_entries = find_generator_gen_entry(mpc, bus); 
     
    % sanity check: are all voltage magnitudes the same?
    if check_voltage_magnitudes(mpc, gen_entries)
        mpc.bus(bus, VM) = mpc.gen(gen_entries(1), VG);
    end
    
    % replace the bus type according 'replace_by'
    if lower(replace_by) == 'pq'        % converts all uppercase characters
        mpc.bus(bus, BUS_TYPE) = PQ;
        for i = 1:numel(gen_entries)
            check_power_generation_at_generators(mpc, gen_entries(i));
        end
        mpc.gen(gen_entries, :) = [];
        if isfield(mpc, 'gencost')
            mpc.('gencost')(gen_entries, :) = [];
        end
    elseif lower(replace_by) == 'pv'
        % when bus type 'ref' -> 'PV', no need to remove generator information from Gen_data
        mpc.bus(bus, BUS_TYPE) = PV;
    else
        error('Unknown bus type `%s`', replace_by);
    end
end

function mpc = replace_slack_and_generators(mpc, trafo_buses)
    slack_bus = find_slack_bus(mpc);   % ref
    % does any trafo_bus correspond to the slack bus?
    trafo_slack_bus = trafo_buses(trafo_buses == slack_bus);
    trafo_buses = [ trafo_slack_bus;
                    setdiff(trafo_buses, trafo_slack_bus) ];
    
    replaced_slack = false;
    for i = 1:numel(trafo_buses)
        trafo_bus = trafo_buses(i);
        if trafo_bus == slack_bus        
            % slack bus and transformer bus coincide
            % hence, replace this generation bus by PQ bus
            warning('The slack bus and the transformer bus coincide.');
            if ~replaced_slack
                mpc = replace_slack(mpc, 'pq'); % replace generator  
                replaced_slack = true;
            end
        else
            % slack bus and transformer bus DO NOT coincide
            warning('The slack bus and the transformer bus DO NOT coincide. Check results carefully.');
            % then, replace transformer bus by PQ bus, I.e. pure load bus
            mpc = replace_generator(mpc, trafo_bus, 'pq');
            % and, replace slack bus by PV bus, gen still working
            if ~replaced_slack
                mpc = replace_slack(mpc, 'pv');
                replaced_slack = true;
            end
        end
    end
end

function mpc = replace_slack(mpc, replace_by)
    slack_bus = find_slack_bus(mpc);
    mpc = replace_generator(mpc, slack_bus, replace_by);
end

