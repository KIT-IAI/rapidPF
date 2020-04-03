clear all; close all; clc;

addpath(genpath('../01_generator/'));
addpath(genpath('../02_splitter/'));
addpath(genpath('../03_parser/'));

names = generate_name_struct();

global use_fmincon
use_fmincon = true;
%% setup
fields_to_merge = {'bus', 'gen', 'branch'};
mpc_trans  = loadcase('case14');
mpc_dist = { loadcase('case30')
             loadcase('case9')  };

connection_array = [2 1 1 2;
%                     1 2 6 13;
%                     1 3 3 2;
                    2 3 2 3; 
                    2 3 13 1;
                    ];

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
% solve problem
[xval, xval_stacked] = validate_distributed_problem_formulation(problem, mpc_split, names);
[xsol, xsol_stacked, mpc_sol] = solve_distributed_problem_centralized(mpc_split, problem, names);
comparison_centralized = compare_results(xval, xsol)

opts = struct( ...
        'rho0',1.5e1,'rhoUpdate',1.1,'rhoMax',1e8,'mu0',1e2,'muUpdate',2,...
        'muMax',2*1e6,'eps',0,'maxiter',30,'actMargin',-1e-6,'hessian','standard',...%-1e-6
        'solveQP','MA57','reg','true','locSol','ipopt','innerIter',2400,'innerAlg', ...
        'none','Hess','standard','plot',true,'slpGlob', true,'trGamma', 1e6, ...
        'Sig','const','term_eps', 0, 'parfor', false, 'reuse', false);
[xsol_aladin, xsol_stack_aladin, mpc_sol_aladin] = solve_distributed_problem_with_aladin(mpc_split, problem, names);
comparison_aladin = compare_results(xval, xsol_aladin)

%% generate centralized problem
% problem_centralized = generate_centralized_power_flow(mpc_split, names);
% [x_sol, x_ref] = solve_centralized_problem_centralized(problem_centralized, mpc_split, names);
% comparison = compare_results(x_sol, xsol_aladin)


