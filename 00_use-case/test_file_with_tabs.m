clear all; close all; clc;

addpath(genpath('../01_generator/'));
addpath(genpath('../02_splitter/'));
addpath(genpath('../03_parser/'));

names = generate_name_struct();
%% setup
fields_to_merge = { 'bus', 'gen', 'branch' };
      
mpc = { loadcase('case14'); loadcase('case30'); loadcase('case9') };
type = { 'trans'; 'dist'; 'dist' };
assert(numel(mpc) == numel(type), 'inconsistent dimensions')
region = [1:numel(mpc)]';
case_files = table(mpc, type, 'RowNames', string(region));
        
connection_array = [1 2 2 4; 3 1 3 6; 2 3 5 7; 2 1 5 5];
connection_table = build_connection_table(connection_array);
N_connections = size(connection_array, 1);

trafo_params.r = 0;
trafo_params.x = 0.00623;
trafo_params.b = 0;
trafo_params.ratio = 0.985;
trafo_params.angle = 0;

trafo_params_array = { trafo_params, trafo_params, trafo_params };

%% global check
% global_check(mpc_dist, trans_connection_buses, dist_connection_buses, trafo_params_array);

%% case-file-generator
for i = 1:numel(mpc)
    mpc_temp = add_connection_info_local(mpc{i}, i, connection_table, names);
    mpc{i} = mpc_temp;
end

fprintf('\nGenerating skeleton system...');
mpc_merge = create_skeleton_mpc(mpc, fields_to_merge, names);
fprintf('done.\n');

for i = 2:height(case_files)
    fprintf('\nMerging system #%i \n', i);
    mpc_merge = merge_transmission_with_distribution(mpc_merge, mpc{i}, fields_to_merge, names);
end

savecase('mpc_merge.m', mpc_merge)


