clear all; close all; clc;

addpath(genpath('../01_generator/'));
addpath(genpath('../02_splitter/'));
addpath(genpath('../03_parser/'));

names = generate_name_struct();
%% setup
fields_to_merge = { 'bus', 'gen', 'branch' };

mpc_trans  = loadcase('case14');

mpc_dist = { loadcase('case30')
             loadcase('case9')
            };
N_dist = numel(mpc_dist);



trans_connection_buses = [ 2, 3 ];
dist_connection_buses = [ 1, 1 ];

connection_array = [2 1 1 2;
%                     1 2 6 13;
                    1 3 3 2;
                    2 3 2 3;
                    2 3 13 1
                    ];

trafo_params.r = 0;
trafo_params.x = 0.00623;
trafo_params.b = 0;
trafo_params.ratio = 0.985;
trafo_params.angle = 0;

[t2_1, t2_2, t3_1, t3_2] = deal(trafo_params);
t2_1.r = 0.0021;
t2_2.r = 0.0022;
t3_1.r = 0.0031;


conn = build_connection_table(connection_array, trafo_params);
Nconnections = height(conn);

%% global check
% global_check(mpc_dist, trans_connection_buses, dist_connection_buses, trafo_params_array);

%% case-file-generator
mpc_merge = create_skeleton_mpc({mpc_trans}, fields_to_merge, names);

% mpc_trans = add_connection_info_local(mpc_trans, 1, connection_table, names);
% for i = 1:numel(mpc_dist)
%     mpc = add_connection_info_local(mpc_dist{i}, i+1, connection_table, names);
%     mpc_dist{i} = mpc;
% end

tab = conn;
Ncount = get_number_of_buses(mpc_trans);
for i = 1:numel(mpc_dist)
    % loop over systems
    fprintf('\nMerging distribution system #%i \n', i);
    merge_info = generate_merge_info_from_table(i+1, tab, fields_to_merge);
    mpc_merge = merge_transmission_with_distribution(mpc_merge, mpc_dist{i}, merge_info, names);
    
    tab = update_connections(tab, i+1, Ncount);
    Ncount = Ncount + get_number_of_buses(mpc_dist{i});
end

savecase('mpc_merge.m', mpc_merge)
%% case-file-splitter
% mpc_split = add_aux_buses(mpc_merge, names);
mpc_split = add_copy_nodes(mpc_merge, conn, names);
mpc_split = add_copy_nodes_to_regions(mpc_split, names);
% mpc_split = add_aux_buses_per_region(mpc_split, names);
mpc_split = split_and_makeYbus(mpc_split, names);
savecase('mpc_merge_split.m', mpc_split);

%% generate problem formulation for aladin
% problem = generate_distributed_problem(mpc_split, names);
% 
% [xval, xval_stacked] = validate_distributed_problem_formulation(problem, mpc_split, names);
% [xsol, xsol_stacked, mpc_sol] = solve_distributed_problem_centralized(mpc_split, problem, names);
% comparison_centralized = compare_results(xval, xsol)
% 
% opts = struct( ...
%         'rho0',1.5e1,'rhoUpdate',1.1,'rhoMax',1e8,'mu0',1e2,'muUpdate',2,...
%         'muMax',2*1e6,'eps',0,'maxiter',30,'actMargin',-1e-6,'hessian','standard',...%-1e-6
%         'solveQP','MA57','reg','true','locSol','ipopt','innerIter',2400,'innerAlg', ...
%         'none','Hess','standard','plot',true,'slpGlob', true,'trGamma', 1e6, ...
%         'Sig','const','term_eps', 0, 'parfor', false, 'reuse', false);
% [xsol_aladin, xsol_stack_aladin, mpc_sol_aladin] = solve_distributed_problem_with_aladin(mpc_split, problem, names);
% comparison_aladin = compare_results(xsol, xsol_aladin)


%% generate centralized problem
% problem_centralized = generate_centralized_power_flow(mpc_split, names);
% [x_sol, x_ref] = solve_centralized_problem_centralized(problem_centralized, mpc_split, names);
% comparison = compare_results(x_sol, xsol_aladin)


