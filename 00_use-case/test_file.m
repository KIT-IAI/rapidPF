clear all; close all; clc;

global NAME_FOR_REGION_FIELD NAME_FOR_CONNECTIONS_FIELD NAME_FOR_AUX_FIELD NAME_FOR_SPLIT_CASE_FILE NAME_FOR_CONNECTIONS_GLOBAL_FIELD NAME_FOR_AUX_BUSES_FIELD
NAME_FOR_REGION_FIELD = 'regions';
NAME_FOR_CONNECTIONS_FIELD = 'connections';
NAME_FOR_CONNECTIONS_GLOBAL_FIELD = 'connections_global';
NAME_FOR_AUX_FIELD = 'connections_with_aux_nodes';
NAME_FOR_SPLIT_CASE_FILE = 'split_case_files';
NAME_FOR_AUX_BUSES_FIELD = 'copy_buses_global';
addpath(genpath('../01_generator/'));
addpath(genpath('../02_splitter/'));
addpath(genpath('../03_parser/'));

names.regions.global = NAME_FOR_REGION_FIELD;
names.regions.global_with_copies = NAME_FOR_AUX_FIELD;
names.regions.local = 'regions_local';
names.regions.local_with_copies = 'regions_local_with_copies';
names.copy_buses.local = 'copy_buses_local';
names.copy_buses.global = NAME_FOR_AUX_BUSES_FIELD;
names.connections.local = NAME_FOR_CONNECTIONS_GLOBAL_FIELD;
names.connections.global = NAME_FOR_CONNECTIONS_FIELD;
names.split = NAME_FOR_SPLIT_CASE_FILE;

%% setup
fields_to_merge = { 'bus', 'gen', 'branch' };

mpc_trans  = loadcase('case14');

mpc_dist = { loadcase('case30')
             loadcase('case9')
            };
N_dist = numel(mpc_dist);

trans_connection_buses = [ 2, 3 ];
dist_connection_buses = [ 1, 1 ];

trafo_params.r = 0;
trafo_params.x = 0.00623;
trafo_params.b = 0;
trafo_params.ratio = 0.985;
trafo_params.angle = 0;

trafo_params_array = { trafo_params, trafo_params };

%% global check
global_check(mpc_dist, trans_connection_buses, dist_connection_buses, trafo_params_array);

%% case-file-generator
mpc_merge = create_skeleton_mpc(mpc_trans, fields_to_merge, names);

for i = 1:numel(dist_connection_buses)
    fprintf('\nMerging distribution system #%i \n', i);
    
    merge_info = generate_merge_info(trans_connection_buses(i), dist_connection_buses(i), trafo_params_array{i}, fields_to_merge);
    mpc_merge = merge_transmission_with_distribution(mpc_merge, mpc_dist{i}, merge_info, names);
end

savecase('mpc_merge.m', mpc_merge)
%% case-file-splitter
mpc_split = add_aux_buses(mpc_merge, names);
mpc_split = add_aux_buses_per_region(mpc_split, names);
mpc_split = split_and_makeYbus(mpc_split, names);
savecase('mpc_merge_split.m', mpc_split);

%% generate problem formulation for aladin
problem = generate_distributed_problem(mpc_split, names);
[xval, xval_stacked] = validate_distributed_problem_formulation(problem, mpc_split, names);
% [sol, xsol, xsol_stacked] = solve_distributed_problem_centralized(mpc_split, problem, names);
% 
% comparison_centralized = compare_results(xval, xsol)

opts = struct( ...
        'rho0',1.5e1,'rhoUpdate',1.1,'rhoMax',1e8,'mu0',1e2,'muUpdate',2,...
        'muMax',2*1e6,'eps',0,'maxiter',30,'actMargin',-1e-6,'hessian','standard',...%-1e-6
        'solveQP','MA57','reg','true','locSol','ipopt','innerIter',2400,'innerAlg', ...
        'none','Hess','standard','plot',true,'slpGlob', true,'trGamma', 1e6, ...
        'Sig','const','term_eps', 0, 'parfor', false);

[xsol_aladin, xsol_stack_aladin] = solve_distributed_problem_with_aladin(mpc_split, problem, names, opts);
comparison_aladin = compare_results(xval, xsol_aladin)
%% generate centralized problem
% problem_centralized = generate_centralized_power_flow(mpc_split, names);
% [x_sol, x_ref] = solve_centralized_problem_centralized(problem_centralized, mpc_split, names);
% comparison = compare_results(x_sol, x_ref)


