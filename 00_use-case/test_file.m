%% check if there is a UIfigure
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
addpath(genpath('../04_solver_extension'));
%% plot option
[options, app] = plot_options;
casefile       = options.casefile;
gsk            = options.gsk;      % generation shift key
problem_type   = options.problem_type;
algorithm      = options.algorithm;
solver         = options.solver;

%% setup
names                = generate_name_struct();
matpower_casefile    = mpc_data(casefile);
[mpc_trans,mpc_dist] = gen_shift_key(matpower_casefile, gsk); % P = P * 0.2
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
% generate distributed problem
problem = generate_distributed_problem_for_aladin(mpc_split, names, problem_type);
problem.solver = solver;
if strcmp(solver, 'Casadi+Ipopt') && strcmp(problem_type, 'feasibility')
    problem = rmfield(problem,'sens');
end

% problem.solver      = 'worhp';
% problem.solver = 'fmincon';
% problem.solver = 'fminunc';
% problem.solver = 'Casadi+Ipopt';

%% solve problem
[xval, xval_stacked] = validate_distributed_problem_formulation(problem, mpc_split, names);
% [xsol, xsol_stacked, mpc_sol] = solve_distributed_problem_centralized(mpc_split, problem, names);
% comparison_centralized = compare_results(xval, xsol)

% opts = struct( ...
%         'rho0',1.5e1,'rhoUpdate',1.2,'rhoMax',1e8,'mu0',1e2,'muUpdate',2,...
%         'muMax',2*1e6,'eps',0,'maxiter',200,'actMargin',-1e-6,'hessian','standard',...%-1e-6
%         'solveQP','quadprog','reg','true','locSol','ipopt','innerIter',2400,'innerAlg', ...
%         'none','Hess','standard','slpGlob', true,'trGamma', 1e6, ...
%         'Sig','const','term_eps', 0, 'parfor', false, 'reuse', false);
if strcmp(options.algorithm, 'aladin')
    opts = struct('maxiter',50, 'solveQP','MA57');
    opts.reg ='false';
    opts.rho0= 1e2;
    % 
    % % opts.regParam = 1e-12;
    [xsol_aladin, xsol_stack_aladin, mpc_sol_aladin, logg] = solve_distributed_problem_with_aladin(mpc_split, problem, names, opts);
    % %%
    comparison_aladin           = compare_results(xval, xsol_aladin)
    compare_constraints_violation(problem, logg);
    % %%
    [a,b,c] = compare_power_flow_between_regions(mpc_sol_aladin, mpc_merge.connections, mpc_split.regions, conn(:,1:2));


elseif strcmp(options.algorithm, 'admm')
    %% admm
    % 


    params.max_iter = 10;
    params.tol = 1e-6;
    params.rou = 1000;
    problem.e  = 0.11;
%     problem.Lambda = 
%     problem.zz0 =  xsol_aladin;

    % [x1_stack, violation_admm, logg_admm] = solve_distributed_problem_with_ADMM(problem, params,xsol_stack_aladin);
    % x1opt = vertcat(x1_stack{:});
    % [x1_deal, xsol_stacked]   = deal_solution(x1opt, mpc_split, names);
    [x2_stack, violation_cadmm, logg_cadmm] = admm_classic(problem, params);
    x2opt = vertcat(x2_stack{:});
    [x2_deal, xsol_stacked] = deal_solution(x2opt, mpc_split, names);

    %%
    % compare_results(xval, x1_deal)
    compare_results(xval, x2_deal)
    % compare_results(x1_deal, x2_deal)
    % 
    % comparison_iter(violation_admm, violation_cadmm)
    % % compare_constraints_violation(problem, e_admm);
end

    %% generate centralized problem
    % problem_centralized = generate_centralized_power_flow(mpc_split, names);
    % [x_sol, x_ref] = solve_centralized_problem_centralized(problem_centralized, mpc_split, names);
%     comparison = compare_results(x_sol, xsol_aladin)
