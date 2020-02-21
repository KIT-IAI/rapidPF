% start merging two case file, with local function executing
% pre-/post-processing check
function mpc = merge_transmission_with_distribution(mpc_trans, mpc_dist, pars)
% INPUT to the function
% mpc_TS -- case file for transmission system with 1..N_TS bus/branch numbering
% mpc_DS -- case file for distribution system with 1..N_DS bus/branch numbering
% trans_connection bus -- bus number from transmission system to which the
% transformer is connected, must be between 1 and N_trans
% dist_connection bus -- bus number from distribution system to which the
% transformer is connected, must be between 1 and N_dist
% params -- transformer/line params: r, x, b, ratio, angle
    global NAME_FOR_CONNECTIONS_FIELD NAME_FOR_CONNECTIONS_GLOBAL_FIELD
    trafo_trans_bus          = pars.transformer.transmission_bus;
    trafo_dist_bus           = pars.transformer.distribution_bus;
    params                   = pars.transformer.params;
    fields_to_merge          = pars.fields_to_merge;
    Nbus_trans               = get_number_of_buses(mpc_trans);       % number of buses in transmission casefile
    
    %% attain the information of distribution before processing    
    params_dist.Nbus         = get_number_of_buses(mpc_dist);
    params_dist.Nbranch      = get_number_of_branches(mpc_dist);
    params_dist.Ngen         = get_number_of_generators(mpc_dist);   %
    params_dist.Ngen_trafo_bus = get_number_of_connected_generators(mpc_dist, trafo_dist_bus);
    
    %% pre-processing sanity check
    pre_processing(mpc_trans, mpc_dist, trafo_trans_bus, trafo_dist_bus, fields_to_merge);
  
    %% main part
    % replace slack bus and connection bus in distribution grid
    mpc_dist = replace_slack_and_generators(mpc_dist, trafo_dist_bus);
    % check whether connecting bus in distribution system is the slack bus
    % merge numbering
    mpc = merge_numbering_and_stack(mpc_trans, mpc_dist, fields_to_merge);
    % add region information
    mpc = add_region_information(mpc, Nbus_trans, params_dist.Nbus);
    mpc = add_edge_information(mpc, trafo_trans_bus, trafo_dist_bus, NAME_FOR_CONNECTIONS_GLOBAL_FIELD);
    % introduce transformer-branch at connection bus
    trafo_from_bus = trafo_trans_bus;
    trafo_to_bus   = trafo_dist_bus + Nbus_trans;
    mpc = add_transformer_branch(mpc, trafo_from_bus, trafo_to_bus, params);
    mpc = add_edge_information(mpc, trafo_from_bus, trafo_to_bus, NAME_FOR_CONNECTIONS_FIELD);
    
    %% post-processing sanity check
    post_processing(mpc_trans, mpc, params_dist);

end

% carry out sanity check before processing, carried out iteratively
function pre_processing(mpc_trans, mpc_dist, trans_connection_buses, dist_connection_buses, field_name)
% INPUT
% mpc_trans            -- case file for trans, in 'struct'
% mpc_dist             -- case file for dist,  in 'struct'
% trans_connection_buses -- buses connected to trasfo in transmission
% dist_connection_buses  -- buses connected to trasfo in distribution
    pre_processing_mpc(mpc_trans, trans_connection_buses, 'transmission', field_name);    
    pre_processing_mpc(mpc_dist, dist_connection_buses, 'distribution', field_name);
    check_baseMVA_between_mpc(mpc_trans, mpc_dist);    
end

function pre_processing_mpc(mpc, buses, msg, field_name)
    check_out_of_service(mpc);
    check_connection(mpc, buses, msg);
    check_baseMVA_within_mpc(mpc);
    check_existence_of_field(mpc, field_name);
end

% check the number of buses, branches and generators in mpc_merge
% check the working state of the merged case-file
function post_processing(mpc_trans, mpc_merge, params_dist)
% INPUT
% mpc_trans   -- case-file for transmission
% mpc_merge   -- combined case-file after merging
% params_dist -- parameters of distribution before the processing
    global NAME_FOR_CONNECTIONS_FIELD
    % transmission
    Nbus_trans    =  get_number_of_buses(mpc_trans);       % number of buses in transmission casefile
    Nbranch_trans =  get_number_of_branches(mpc_trans);    % .......... branch ...
    Ngen_trans    =  get_number_of_generators(mpc_trans);  % ...........generators ...
    % distribution
    Nbus_dist     =  params_dist.Nbus;    
    Nbranch_dist  =  params_dist.Nbranch; 
    Ngen_dist     =  params_dist.Ngen;    
    Ngen_trafo_dist_bus = params_dist.Ngen_trafo_bus;

    % combined model
    Ngen_mpc      =  get_number_of_generators(mpc_merge);

    check_number_of_buses(Nbus_trans,Nbus_dist,mpc_merge)
    check_number_of_branches(Nbranch_trans,Nbranch_dist,mpc_merge)
    check_number_of_generators(Ngen_trans, Ngen_dist, Ngen_trafo_dist_bus, Ngen_mpc);
    
    edges = mpc_merge.(NAME_FOR_CONNECTIONS_FIELD){end};
    check_for_line(mpc_merge, edges(1), edges(2));

    % check whether new coupled case would work
    check_out_of_service(mpc_merge);
    check_baseMVA_within_mpc(mpc_merge);        
end

function bool = check_for_line(mpc, from_bus, to_bus)
    [F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, ...
        RATE_C, TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
        ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
    from_buses = mpc.branch(:, F_BUS);
    to_buses = mpc.branch(:, T_BUS);
    
    
    if sum(find(from_buses == from_bus & to_buses == to_bus)) == 0
        bool = false;
        error('Something is wrong with the added transformer branch');
    else
        bool = true;
    end
end

% check whether the gnenerators is out-of-serve, (ref: Manual Table B-2)
function bool = check_out_of_service(mpc)
% INPUT
% mpc -- casefile
    [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
        MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
        QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
    % check whether ALL generators are in-service
    if sum(mpc.gen(:, GEN_STATUS) <= 0) > 0
        bool = false;
        error('Some generator is out of service. Please check.')
    else
        bool = true;
    end
end

% check whether the connected bus is a PV / ref bus
% error when the bus is a PQ bus, I.e. non-generator bus
function check_connection(mpc, bus, sys)
% INPUT:
% mpc: current casefile
% bus: bus number for connection in mpc
% sys: system name
    if ~is_generator(mpc, bus)
        error('[%s system] Transformer would be connected to a non-generation bus.', sys)
    end
end

% check whether baseMVAs in mpc and in Generators-Data are the same
function bool = check_baseMVA_within_mpc(mpc)
    [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
        MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
        QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
    if sum(mpc.gen(:, MBASE) ~= mpc.baseMVA) > 0
%         if numel(find(mpc.gen(:, MBASE) ~= mpc.baseMVA)) > 0
        bool = false;
        error('Inconsistent baseMVA values detected.')
    else
        bool = true;
    end
end

% error when these two mpcs have different baseMVA value 
function bool = check_baseMVA_between_mpc(mpc1, mpc2)
    if mpc1.baseMVA ~= mpc2.baseMVA
        bool = false;
        error('Two case files have different baseMVAs.')
    else
        bool = true;
    end
end

% error when required field doesn't exist in casefile
function check_existence_of_field(mpc, field_name)
    if ~isfield(mpc, field_name)
        error('The field %s doest not exist for struct %s', field_name, get_name_of_variable(mpc));
    end
end

% check the number of buses in merged case-file is as expected
% N_transmission_system + N_distribution_system = size(mpc.bus,1) for 
function check_number_of_buses(N_transmission_system, N_distribution_system, mpc)
    N_mpc = size(mpc.bus, 1);
    % check 1:N numbering
    if N_transmission_system + N_distribution_system ~= N_mpc
        error('Total number of buses is not equal to the `sum of number of buses in both subsystems` .');
    end
end

% check the number of branches in merged case-file is as expected
% M_transmission_system + M_distribution_system +1 = size(mpc.branch,1) 
function check_number_of_branches(M_transmission_system, M_distribution_system, mpc)
    M_mpc = size(mpc.branch, 1);
    % check 1:N numbering
    if M_transmission_system + M_distribution_system + 1 ~= M_mpc
        error('Total number of branches is not equal to the `sum of number of branches in both subsystems` + 1.');
    end
end

% check the number of generators in merged case-file is as expected
% error when the Ngen_trans + Ngen_dist - Ngen_trafo_dist_bus ~= Ngen_mpc
function bool = check_number_of_generators(Ngen_trans, Ngen_dist, Ngen_trafo_dist_bus, Ngen_mpc)
% INPUT
% Ngen_trans -- the number of generators in transmission
% Ngen_dist  -- the number of generators in distribution
% Ngen_trafo_dist_bus -- the number of generators to be removed in the
% distribution system
% Ngen_mpc   -- the number of generators in the mpc after merging
    if Ngen_trans + Ngen_dist - Ngen_trafo_dist_bus == Ngen_mpc
        bool = true;
    else
        bool = false;
        error('There is something wrong the number of generators (expected %i, got %i)', Ngen_trans + Ngen_dist - Ngen_trafo_dist_bus, Ngen_mpc);
    end
end