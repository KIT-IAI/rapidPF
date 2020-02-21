clear all;
clc;

global NAME_FOR_REGION_FIELD NAME_FOR_CONNECTIONS_FIELD
NAME_FOR_REGION_FIELD = 'regions';
NAME_FOR_CONNECTIONS_FIELD = 'connections';
addpath(genpath('fun'))
%%
fields_to_merge = { 'bus', 'gen', 'branch',};

mpc_trans  = loadcase('case14');

mpc_dist = { loadcase('case5');
             loadcase('case9')
            };

trans_connection_buses = [ 2; 3 ];
dist_connection_buses = [ 1; 1 ];

trafo_params.r = 0;
trafo_params.x = 0.00623;
trafo_params.b = 0;
trafo_params.ratio = 0.985;
trafo_params.angle = 0;

trafo_params_array = { trafo_params; trafo_params };

%% global check
global_check(mpc_dist, trans_connection_buses, dist_connection_buses, trafo_params_array);

%% combine all case files
mpc_merge = create_skeleton_mpc(mpc_trans, fields_to_merge);

for i = 1:numel(dist_connection_buses)
    fprintf('\nMerging distribution system #%i \n', i);
    
    merge_info = generate_merge_info(trans_connection_buses(i), dist_connection_buses(i), trafo_params_array{i}, fields_to_merge);
    mpc_merge = merge_transmission_with_distribution(mpc_merge, mpc_dist{i}, merge_info);
end

savecase('mpc_merge.m', mpc_merge)