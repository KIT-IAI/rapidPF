clear all;
clc;

global NAME_FOR_REGION_FIELD
NAME_FOR_REGION_FIELD = 'regions';
addpath(genpath('fun'))
%% create case file
fields_to_merge = { 'bus', 'gen', 'branch' };

mpc_trans  = loadcase('case14');

mpc_dist = { loadcase('case9');
             loadcase('case9')
            };

trans_connection_buses = [ 2; 3 ];
dist_connection_buses = [ 2; 2 ];

trafo_params.r = 0;
trafo_params.x = 0.00623;
trafo_params.b = 0;
trafo_params.ratio = 0.985;
trafo_params.angle = 0;

trafo_params_array = { trafo_params; trafo_params };


%% testing
MBASE = 7;
GEN_STATUS = 8;
VG    = 6;

%% different baseMVA values between transmission and distribution
% mpc_trans.baseMVA = 150;          % transmission
% mpc_dist{2}.baseMVA = 120;        % distribution

%% different baseMVA value in gen_data
% mpc_trans.gen(1,MBASE) = 120;         % transmission
% mpc_dist{2}.gen(1,MBASE) = 120;       % distribution

%% trasfo is connected to a non-generator bus
% trans_connection_buses = [ 4; 3 ];
% dist_connection_buses = [4, 1];

%% relevant field doesn't exist


%% generators out-of-serve
% mpc_trans.gen(1,GEN_STATUS)=-1;
% mpc_dist{2}.gen(2,GEN_STATUS)=-1;

%% size of input data incompatible
%  dist_connection_buses = [1];
% trans_connection_buses = [1];
% mpc_dist = mpc_dist{1};

%% unique generator connection
% trans_connection_buses = [2;2];

%% voltage magnitues


%% global check
global_check(mpc_dist, trans_connection_buses, dist_connection_buses, trafo_params_array);
 
%% start merging
mpc_merge = create_skeleton_mpc(mpc_trans, fields_to_merge);
for i = 1:numel(dist_connection_buses)
    fprintf('\nMerging distribution system #%i \n', i);
    
    merge_info = generate_merge_info(trans_connection_buses(i), dist_connection_buses(i), trafo_params_array{i}, fields_to_merge);
    mpc_merge = merge_transmission_with_distribution(mpc_merge, mpc_dist{i}, merge_info);
end