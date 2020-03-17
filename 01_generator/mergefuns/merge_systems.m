function mpc = merge_systems(mpc_master, mpc_slave, pars, names)
% merge_systems
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

    % check whether new coupled case would work
    check_out_of_service(mpc_merge);
    check_baseMVA_within_mpc(mpc_merge);        
end

function check_for_line(mpc, from_bus, to_bus)
    [F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, ...
        RATE_C, TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
        ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
    from_buses = mpc.branch(:, F_BUS);
    to_buses = mpc.branch(:, T_BUS);
    assert(sum(find(from_buses == from_bus & to_buses == to_bus)) > 0, 'post_processing:check_for_line', 'Something is wrong with the added transformer branch')
end

% check whether the gnenerators is out-of-serve, (ref: Manual Table B-2)
function check_out_of_service(mpc)
% INPUT
% mpc -- casefile
    [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
        MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
        QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
    % check whether ALL generators are in-service
    assert(sum(mpc.gen(:, GEN_STATUS) <= 0) == 0, 'post_processing:check_out_of_service', 'Some generator is out of service. Please check.')
end

% check whether the connected bus is a PV / ref bus
% error when the bus is a PQ bus, I.e. non-generator bus
function check_connection(mpc, bus, sys)
% INPUT:
% mpc: current casefile
% bus: bus number for connection in mpc
% sys: system name
    assert(is_generator(mpc, bus), 'post_processing:check_connection', '[%s system] Transformer would be connected to a non-generation bus.', sys)
end

% check whether baseMVAs in mpc and in Generators-Data are the same
function check_baseMVA_within_mpc(mpc)
    [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
        MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
        QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
    
    assert(sum(mpc.gen(:, MBASE) ~= mpc.baseMVA) == 0, 'post_processing:baseMVA_inconsistent_within_mpc', 'Inconsistent baseMVA values detected.')
end

% error when these two mpcs have different baseMVA value 
function check_baseMVA_between_mpc(mpc1, mpc2)
    assert(mpc1.baseMVA == mpc2.baseMVA, 'post_processing:baseMVA_inconsistent_between_mpc', 'Two case files have different baseMVAs.')
end

% error when required field doesn't exist in casefile
function check_existence_of_field(mpc, field_name)
    assert(isfield(mpc, field_name), 'post_processing:check_existence_of_field', 'The field `%s` does not exist for struct %s', field_name, get_name_of_variable(mpc))
end

% check the number of buses in merged case-file is as expected
% N_transmission_system + N_distribution_system = size(mpc.bus,1) for 
function check_number_of_buses(N_transmission_system, N_distribution_system, mpc)
    N_mpc = size(mpc.bus, 1);
    % check 1:N numbering
    assert(N_transmission_system + N_distribution_system == N_mpc, 'post_processing:check_number_of_buses', 'Total number of buses is not equal to the `sum of number of buses in both subsystems` .')
end

% check the number of branches in merged case-file is as expected
% M_transmission_system + M_distribution_system +1 = size(mpc.branch,1) 
function check_number_of_branches(M_transmission_system, M_distribution_system, M_conn, mpc)
    M_mpc = size(mpc.branch, 1);
    assert(M_transmission_system + M_distribution_system + M_conn == M_mpc, 'post_processing:check_number_of_branches', 'Total number of branches is not equal to the `sum of number of branches in both subsystems` + 1.')
end

% check the number of generators in merged case-file is as expected
% error when the Ngen_trans + Ngen_dist - Ngen_trafo_dist_bus ~= Ngen_mpc
function check_number_of_generators(Ngen_trans, Ngen_dist, Ngen_trafo_dist_bus, Ngen_mpc)
    % INPUT
    % Ngen_trans -- the number of generators in transmission
    % Ngen_dist  -- the number of generators in distribution
    % Ngen_trafo_dist_bus -- the number of generators to be removed in the
    % distribution system
    % Ngen_mpc   -- the number of generators in the mpc after merging
    assert(Ngen_trans + Ngen_dist - sum(Ngen_trafo_dist_bus) == Ngen_mpc, 'post_processing:check_number_of_generators', 'There is something wrong the number of generators (expected %i, got %i).', Ngen_trans + Ngen_dist - Ngen_trafo_dist_bus, Ngen_mpc)
end