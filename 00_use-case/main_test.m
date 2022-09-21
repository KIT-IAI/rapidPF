% check if there is a UIfigure
if exist('app','var')
    % close UIfigure
    delete(app.UIFigure)
end
%%
clc
clear
close all

addpath(genpath('../00_use-case/'));
addpath(genpath('../01_generator/'));
addpath(genpath('../02_splitter/'));
addpath(genpath('../03_parser/'));
addpath(genpath('../04_aladin/'));
%% plot option
[options, app] = plot_options;
casefile       = options.casefile;
%%
gsk            = 0;options.gsk;      % generation shift key
problem_type   = options.problem_type;
algorithm      = options.algorithm;
solver         = options.solver;


% casefile       = '120';
% gsk            = 0;      % generation shift key
% problem_type   = 'least-squares';
% algorithm      = 'aladin';
% solver         = 'fmincon';

% setup
gsk = 0;
names                = generate_name_struct();
matpower_casefile    = mpc_data(casefile);
decreased_region     =1;
[mpc_trans,mpc_dist] = gen_shift_key(matpower_casefile, decreased_region, gsk); % P = P * 0.2
fields_to_merge      = matpower_casefile.fields_to_merge;
connection_array     = matpower_casefile.connection_array;


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
% choose problem dimension
state_dimension = 'full';
% state_dimension = 'half';

% generate distributed problem
problem = generate_distributed_problem_for_aladin(mpc_split, names, problem_type, state_dimension);
problem.solver = solver;
if strcmp(solver, 'Casadi+Ipopt') && strcmp(problem_type, 'feasibility')
    problem = rmfield(problem,'sens');
end


% problem.solver      = 'worhp';
% problem.solver = 'fmincon';
% problem.solver = 'fminunc';
%problem.solver = 'Casadi+Ipopt';

%% solve problem
 [xval, xval_stacked] = validate_distributed_problem_formulation(problem, mpc_split, names);
% [xsol, xsol_stacked, mpc_sol] = solve_distributed_problem_centralized(mpc_split, problem, names);
% comparison_centralized = compare_results(xval, xsol)
%%
% start local nlp
% initial setting
% load lam0_35.mat
% problem.lam0 = lam0_140(:,7);

option              = AladinOption;
option.problem_type = problem_type;
option.iter_max  = 20;
option.tol       = 1e-8;
option.mu0       = 1e2;
option.rho0      = 1e2;
option.nlp       = NLPoption;
% option.nlp.solver = 'mldivide'; %solver;
% option.nlp.solver = 'cg_steihaug';
option.nlp.solver = 'mldivide';
% option.nlp.solver = 'MA57';
% option.nlp.solver = 'casadi';
option.nlp.iter_display = true;
option.qp        = QPoption;
option.qp.regularization_hess = false;
% option.qp.solver = 'lsqlin';
% option.qp.solver = 'lsqminnorm';
option.qp.solver = 'mldivide';
% option.qp.solver = 'MA57';
% option.qp.solver = 'cg_steihaug';
% option.qp.solver = 'lu';
% start alg
tic
[xsol, xsol_stacked,logg] = solve_rapidPF_aladin(problem, mpc_split, option, names);
toc
% back to mpc
%mpc_sol_aladin = back_to_mpc(mpc_split, xsol, logg);

% compare result
[tab,~,error] = compare_results(xval, xsol)
% compare_constraints_violation(problem, logg);
%compare_power_flow_between_regions(mpc_sol_aladin, mpc_merge.connections, mpc_split.regions, conn(:,1:2));
% deviation_violation_iter_plot(mpc_split, xval, logg, names);
%tab
%error