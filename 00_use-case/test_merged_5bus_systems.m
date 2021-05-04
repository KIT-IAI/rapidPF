
clc
clear
close all

% branch idx
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
% gen idx

names                = generate_name_struct();
mpc.fields_to_merge = {'bus', 'gen', 'branch', 'gencost'};

mpc_temp = loadcase('case5');

% mpc_temp.branch(:, RATE_A) = 0;
% mpc_temp.branch(:, RATE_B) = 0;
% mpc_temp.branch(:, RATE_C) = 0;

mpc.trans = mpc_temp;
mpc.dist = { mpc_temp};

mpc.connection_array = [ 1 2 1 5];

 mpc.trans = mpc_temp;
 mpc.dist = { mpc_temp;
              mpc_temp
                     };
 
  mpc.connection_array = [ 1 2 1 5;
                         2 3 1 5];

% connected a from generator to a to generator with much higher Pmax 
%% 

% [mpc_trans,mpc_dist] = gen_shift_key(mpc, gsk); % P = P * 0.2
fields_to_merge      = mpc.fields_to_merge;
connection_array     = mpc.connection_array;


trafo_params.r = 0;
trafo_params.x = 0.00623;
trafo_params.b = 0;
trafo_params.ratio = 0.985;
trafo_params.angle = 0;

conn = build_connection_table(connection_array, trafo_params);
Nconnections = height(conn);

%% main
% case-file-generator
mpc_merge = run_case_file_generator(mpc.trans, mpc.dist, conn, fields_to_merge, names);
mpc_split = run_case_file_splitter(mpc_merge, conn, names);

split_file_1  = mpc_split.split_case_files{1, 1};
split_file_2 = mpc_split.split_case_files{2, 1};

runopf(mpc_merge);

problem = generate_distributed_opf_for_aladin(mpc_split, names, 'feasibility');

mpopt = mpoption('out.lim.all', 2, 'opf.return_raw_der', 1);
result_opf = runopf(mpc_merge, mpopt);
% [f, df, d2f] = opf_costfcn(result_opf.x, result_opf.om);
% [h, g, dh, dg] = opf_consfcn(result_opf.x, result_opf.om);
% 
% x = result_opf.x;
% x1 = vertcat(x(1:5), x(10), x(11:15), x(20), x(21:25), x(30:34));
% x1_test = get_local_variable_from_global_objective_variable(x, 1, mpc_split, names);
% x2 = vertcat(x(6:10), x(1), x(16:20), x(11), x(26:29), x(35:38));
% x2_test = get_local_variable_from_global_objective_variable(x, 2, mpc_split, names);
% x3_test = get_local_variable_from_global_objective_variable(x, 3, mpc_split, names);
% 
% fx1 = problem.locFuns.ffi{1}(x1_test);
% fx2 = problem.locFuns.ffi{2}(x2_test);
% fx3 = problem.locFuns.ffi{3}(x3_test);
% 
% diff_f = result_opf.f - (fx1 + fx2 + fx3);
% 
% gx1 = problem.locFuns.ggi{1}(x1_test);
% gx2 = problem.locFuns.ggi{2}(x2_test);
% gx3 = problem.locFuns.ggi{3}(x3_test);
% 
% hx1 = problem.locFuns.hhi{1}(x1_test);
% hx2 = problem.locFuns.hhi{2}(x2_test);
% hx3 = problem.locFuns.hhi{3}(x3_test);
% 
% consensus = problem.AA{1}*x1_test + problem.AA{2}*x2_test + problem.AA{3}*x3_test;
%% ALADIN-alpha
% 
% problem.solver = 'fmincon';
% % [xval, xval_stacked] = validate_distributed_problem_formulation(problem, mpc_split, names);
% 
% % solve distributed ALADIN
% 
% opts = struct('maxiter',50, 'solveQP','ipopt');
% opts.reg ='false';
% opts.rho0= 1e2;
% opts.maxiter = 20;
% [xsol_aladin, xsol_stack_aladin, mpc_sol_aladin, logg] = solve_distributed_problem_with_aladin(mpc_split, problem, names, opts);
%% ALADIN-OOP
option           = AladinOption;
option.iter_max  = 20;
option.tol       = 1e-8;
option.mu0       = 1e4;
option.rho0      = 1e4;
option.nlp       = NLPoption;
option.nlp.solver = 'fmincon';
option.nlp.iter_display = true;
option.nlp.active_set = true;
option.qp        = QPoption;
% option.qp.regularization_hess = true;
% option.qp.solver = 'lsqminnorm';
% option.qp.solver = 'lsqlin';
option.qp.solver = 'casadi';




for i = 1 : length(problem.AA)
    local_funs = originalFuns(problem.locFuns.ffi{i}, problem.sens.gg{i}, problem.sens.HH{i}, problem.AA{i}, [], [], problem.locFuns.ggi{i}, problem.sens.JJac_eq{i}, problem.locFuns.hhi{i}, problem.sens.JJac_ineq{i});
    nlps(i)    = localNLP(local_funs,option.nlp,problem.llbx{i},problem.uubx{i});
end

[xopt,logg] = run_aladin_algorithm(nlps,problem.zz0,problem.lam0,horzcat(problem.AA{:}),problem.b,option);
%% validation

% compare ALADIN_Alex with ALADIN_OOP
%diff_aladin_alpha_oop = xopt - xsol_aladin;

% compare ALADIN_Alex with run_opf solution
n_regions = size(mpc_merge.regions, 2);
x = cell(n_regions, 1);
x_ref = [];
for i = 1 : n_regions
    x{i, 1} = get_local_variable_from_global_objective_variable(result_opf.x, i, mpc_split, names);
    x_ref = vertcat(x_ref, x{i, 1});
end
% diff_aladin_alpha_runopf = x_ref - xsol_aladin;

% compare ALADIN_OOP with run_opf solution
diff_aladin_oop_runopf = x_ref - xopt;


%% validation old
% opts = mpoption;
% % fix deviation
% opts.opf.violation = 1e-8;
% mpc_merge = runopf(mpc_merge,opts);
% % initialize local NLP problem by extracting data from rapidPF problem
% Nregion = 2;
% baseMVA = 100;
% nlps(Nregion,1)     = localNLP;
% mpc_split = run_case_file_splitter(mpc_merge, conn, names);
% mpc = mpc_split;
% GEN_BUS = 1;
% VA = 9;
% VM =8;
% PG=2;
% QG=3;
% for i = 1:Nregion
%     mpc_local = mpc_split.split_case_files{i};
%     gen_idx             =   ismember(mpc_local.regions,mpc_local.gen(:,GEN_BUS));
%     gen_bus_entries     =   find(gen_idx);     % entries of bus data
% 
%     gen_bus_global      =   mpc_local.bus(gen_bus_entries,GEN_BUS);
%     gencost_idx_global = find(ismember(mpc.gen(:,GEN_BUS), gen_bus_global));
%     Vang_opt = mpc_local.bus(:,VA)/180*pi;
%     Vmag_opt = mpc_local.bus(:,VM);
% %     gencost haven't been splitted - complicated - need to be simplified
%     Pg_opt   = mpc.gen(gencost_idx_global,PG)/baseMVA;
%     Qg_opt   = mpc.gen(gencost_idx_global,QG)/baseMVA;
%     xsol{i} = stack_state(Vang_opt,Vmag_opt,Pg_opt,Qg_opt);
% end
% XOPT = vertcat(xsol{:});
% logg.plot_distance(XOPT);
% dx = xopt-XOPT
% dx_norm = norm(dx,inf)

% [xsol_aladin, xsol_stack_aladin, mpc_sol_aladin, logg] = solve_distributed_problem_with_aladin(mpc_split, problem, names, opts);