clc;
clear;
close all;

addpath(genpath('../00_use-case/'));
addpath(genpath('../01_generator/'));
addpath(genpath('../02_splitter/'));
addpath(genpath('../03_parser/'));
addpath(genpath('../04_solver_extension'));
addpath(genpath('../06_opf_extension'));

%% setup
names                = generate_name_struct();
mpc.fields_to_merge = {'bus', 'gen', 'branch', 'gencost'};

mpc_temp = loadcase('case5');
% mpc_temp.gencost(:, 4) = 3;
% mpc_temp.gencost(:, 6:7) = rand();

% remove limits in casefile
% generator limits
% upper bounds

% line flow limits
% upper bounds
% mpc_temp.branch(:, 6) = 0;

%mpc.fields_to_merge = {'bus', 'gen', 'branch'};
% mpc.trans = mpc_temp;
% mpc.dist = { mpc_temp;
%              mpc_temp
%                     };
% 
% mpc.connection_array = [ 1 2 1 5;
%                          2 3 4 1];
%                      

        mpc.trans  = ext2int(loadcase('case9'));
        mpc.dist = { ext2int(loadcase('case9'))};
                            % region 1 - region 2
        mpc.connection_array = [
                            % region 1 - region 2
                            1 2 2 1

                            ]; 

% compatibility tests
% Opf data is provided ??
assert(isfield(mpc.trans, 'gencost'),...
'The master casefile does not provide data for generator costs');
for i = 1 : length(mpc.dist)
    assert(isfield(mpc.dist{i, 1}, 'gencost'), ...
        strcat('The slave casefile ', int2str(i), ...
        ' does not provide data for genertor '));
end

% Data compatible ??- at the moment only real power
% optimization is supportet
assert(size(mpc.trans.gencost, 1) == size(mpc.trans.gen, 1),...
    strcat('The master casefile provides data for real and reacitve power',...
    'generation. Please provide only casefiles that do not provide', ...
    'data for reactive power generation'));
for i = 1: length(mpc.dist)
    assert(size(mpc.dist{i, 1}.gencost, 1) == size(mpc.dist{i, 1}.gen, 1),  strcat('The slave casefile ', int2str(i)', ' provides data for real and reacitve power generation. Please provide only casefiles that do not provide data for reactive power generation'));    
end



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


% sanity
% total demand is higher than available total generator power
assert(sum(mpc_merge.gen(:, 9)) > sum(mpc_merge.bus(:, 3)), ...
    'Total demand is larger than total available generation power')

% opf tests
% delete flow limits
if ~sum(abs(mpc_merge.branch(:, 6))) == 0
    warning('Flow limits are not yet implemented for opf and corresponding entries got deleted');
end
% mpc_merge.branch(:, 6) = zeros(size(mpc_merge.branch(:, 6), 1), 1);

% case-file-splitter
mpc_split = run_case_file_splitter(mpc_merge, conn, names);

%% run opf of merged file
% runopf(mpc_merge);
% runpf(mpc_merge);
%% setup distributed opf
% start values from pf

%% solve pf

 mpc_split = run_case_file_splitter(mpc_merge, conn, names);
 problem_type = 'feasibility';
 % generate distributed problem
 problem = generate_distributed_pf_for_aladin(mpc_split, names, problem_type);
 problem.solver = 'fmincon';


    opts = struct('maxiter',50, 'solveQP','quadprog');
    opts.reg ='false';
    opts.rho0= 1e2;
    % 
    % % opts.regParam = 1e-12;
 %   [xsol_aladin, xsol_stack_aladin, mpc_sol_aladin, logg] = solve_distributed_problem_with_aladin(mpc_split, problem, names, opts);
    %%
%    comparison_aladin    = compare_results(xval, xsol_aladin)
%    violation            = compare_constraints_violation(problem, logg);
    %%
%    [a,b,c] = compare_power_flow_between_regions(mpc_sol_aladin, mpc_merge.connections, mpc_split.regions, conn(:,1:2));
    %% 
%    deviation = deviation_violation_iter_plot(mpc_split, xval, logg, names, xsol_aladin);


%% solve opf problem




% generate distributed problem
problem = generate_distributed_opf_for_aladin(mpc_split, names, 'feasibility');

% 
% option           = AladinOption;
% option.iter_max  = 15;
% option.tol       = 1e-8;
% option.mu0       = 1e3;
% option.rho0      = 1e2;
% option.nlp       = NLPoption;
% option.nlp.solver = 'casadi';
% option.nlp.iter_display = true;
% option.nlp.active_set = true;
% option.qp        = QPoption;
% % option.qp.regularization_hess = true;
% % option.qp.solver = 'lsqminnorm';
% % option.qp.solver = 'lsqlin';
% option.qp.solver = 'casadi';
% 
% 
% 
% 
% for i = 1 : length(problem.AA)
%     local_funs = originalFuns(problem.locFuns.ffi{i}, [], [], problem.AA{i}, [], [], problem.locFuns.ggi{i}, [], problem.locFuns.hhi{i}, []);
%     nlps(i)    = localNLP(local_funs,option.nlp,problem.llbx{i},problem.uubx{i});
% end
% [xopt,logg] = run_aladin_algorithm(nlps,problem.zz0,problem.lam0,horzcat(problem.AA(:)),problem.b,option);
% 
% 
% 
% 
% for i = 1:Nregion
% 
%     local_funs = originalFuns(fi{i}, [], [], AA{i}, [], [], con_eq{i}, [], con_ineq{i}, []);
% 
%     nlps(i)    = localNLP(local_funs,option.nlp,lbx{i},ubx{i});
% 
% end
% 
% [xopt,logg] = run_aladin_algorithm(nlps,x0,lam0,A,b,option); 



problem.solver = 'fmincon';
% [xval, xval_stacked] = validate_distributed_problem_formulation(problem, mpc_split, names);

% solve distributed ALADIN

opts = struct('maxiter',50, 'solveQP','quadprog');
opts.reg ='false';
opts.rho0= 1e2;
opts.maxiter = 50;
    
[xsol_aladin, xsol_stack_aladin, mpc_sol_aladin, logg] = solve_distributed_problem_with_aladin(mpc_split, problem, names, opts);