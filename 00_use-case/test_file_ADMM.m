clear all; close all; clc;

addpath(genpath('../01_generator/'));
addpath(genpath('../02_splitter/'));
addpath(genpath('../03_parser/'));
addpath(genpath('../ADMM_comparison/'));


names = generate_name_struct();
%% setup
fields_to_merge = {'bus', 'gen', 'branch'};
mpc_trans  = loadcase('case14');
%% bus: 14+9 = 33
%mpc_dist = { loadcase('case9')};

%connection_array = [2 1 1 2;
%                    2 1 2 3;
%                    ];
%% bus: 14+30+9 = 53
mpc_dist = { loadcase('case30')
             loadcase('case9')  };

connection_array = [2 1 1 2;
                    2 3 2 3; 
                    2 3 13 1;
                    ];                
%%               
trafo_params.r = 0;
trafo_params.x = 0.00623;
trafo_params.b = 0;
trafo_params.ratio = 0.985;
trafo_params.angle = 0;

conn = build_connection_table(connection_array, trafo_params);
Nconnections = height(conn);
%% main
% case-file-generator
mpc_merge = run_case_file_generator(mpc_trans, mpc_dist, conn, fields_to_merge, names);
% case-file-splitter
mpc_split = run_case_file_splitter(mpc_merge, conn, names);
% generate problem formulation for aladin
problem = generate_distributed_problem_for_aladin(mpc_split, names);
%% compare against validation solution
[xval, xval_stacked] = validate_distributed_problem_formulation(problem, mpc_split, names);
%% ALADIN
[xsol_aladin, xsol_stack_aladin, mpc_sol_aladin] = solve_distributed_problem_with_aladin(mpc_split, problem, names);

%% compare ADMM toolboxes from alex and xinliang 
ADMM_comparision_state_iterately(mpc_split, problem, xval, names);

%% compare with different rho
ADMM_comparison_different_rho(mpc_split, problem, xval, names);

%% initial point near ref
ADMM_initial_point_near_ref(mpc_split, problem, xval, names, xsol_stack_aladin)

%% rho update
ADMM_rho_update(mpc_split, problem, xval, names);

%%
for i = 1:numel(problem.zz0)
    dx(i) = norm(xsol_stack_aladin{i} - problem.zz0{i}, 2);
end
dx = norm(dx,2);



