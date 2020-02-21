clear all;
clc;

global NAME_FOR_REGION_FIELD
NAME_FOR_REGION_FIELD = 'regions';
addpath(genpath('fun'))
%%
mpc_trans  = loadcase('case14');
mpc_dist_1 = loadcase('case9');



trans_connection_bus(1) = 2;
dist_1_connection_bus = 2;

% unique check
check_availability_of_trans_bus(trans_connection_bus);

trafo_params.r = 0;
trafo_params.x = 0.00623;
trafo_params.b = 0;
trafo_params.ratio = 0.985;
trafo_params.angle = 0;

fields_to_merge = { 'bus', 'gen', 'branch' };

merge_info = generate_merge_info(trans_connection_bus(1), dist_1_connection_bus, trafo_params, fields_to_merge);

mpc_merge = create_skeleton_mpc(mpc_trans, fields_to_merge);

mpc_merge = merge_transmission_with_distribution(mpc_merge, mpc_dist_1, merge_info)


%%
mpc_dist_2 = loadcase('case9');

trans_connection_bus(2) = 3;
dist_2_connection_bus = 1;

% unique check
check_availability_of_trans_bus(trans_connection_bus);

trafo_params.r = 0;
trafo_params.x = 0.00723;
trafo_params.b = 0;
trafo_params.ratio = 0.965;
trafo_params.angle = 0;

fields_to_merge = { 'bus', 'gen', 'branch' };

merge_info = generate_merge_info(trans_connection_bus(2), dist_2_connection_bus, trafo_params, fields_to_merge);

mpc_merge = merge_transmission_with_distribution(mpc_merge, mpc_dist_2, merge_info)




