
clc
clear
close all

addpath(genpath('../00_use-case/'));
addpath(genpath('../01_generator/'));
addpath(genpath('../02_splitter/'));
addpath(genpath('../03_parser/'));
addpath(genpath('../04_solver_extension'));

%% setup
names                = generate_name_struct();
mpc.fields_to_merge = {'bus', 'gen', 'branch', 'gencost'};
%mpc.fields_to_merge = {'bus', 'gen', 'branch'};
mpc.trans = loadcase('case5');
mpc.dist = { loadcase('case5');
             loadcase('case5')
                    };

mpc.connection_array = [ 1 2 1 5;
                         2 3 4 1];

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


% generate distributed problem
problem = generate_distributed_problem_for_aladin(mpc_split, names, 'feasibility');
problem.solver = 'fmincon';
[xval, xval_stacked] = validate_distributed_problem_formulation(problem, mpc_split, names);

% solve distributed ALADIN

opts = struct('maxiter',50, 'solveQP','MA57');
opts.reg ='false';
opts.rho0= 1e2;
    
[xsol_aladin, xsol_stack_aladin, mpc_sol_aladin, logg] = solve_distributed_problem_with_aladin(mpc_split, problem, names, opts);