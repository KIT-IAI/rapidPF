clear all; close all; clc;

addpath(genpath('../01_generator/'));
addpath(genpath('../02_splitter/'));
addpath(genpath('../03_parser/'));

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

[xsol_alex, xsol_alex_stacked, mpc_alex] = solve_distributed_problem_with_aladin_admm(mpc_split, problem, names);
comparison_aladin = compare_results(xval, xsol_alex)

[xsol_xinliang, xsol_xinliang_stacked, mpc_xinlian] = solve_distributed_problem_with_admm_xinliang(mpc_split, problem, names);
comparison_aladin = compare_results(xval, xsol_xinliang)
%% ADMM test
clc
params.max_iter = 50;
params.tol = 1e-5;
params.rou = 1000;
[x,violation_admm, iter] = solve_distributed_problem_with_ADMM(problem, params);

%% alex code
opts.scaling = false;
opts.rho = 1000;
opts.maxIter = 50;
opts.rhoUpdate = false;
solADM = run_ADMMnew(problem,opts);

% terminate condition check
A  = horzcat(problem.AA{:});
violation_alex  = [];
for i = 1:opts.maxIter
    violation_alex(i) = norm(A*solADM.logg.X(:,i),inf);
end

%% compare the x_opt
x_alex = cell2mat(solADM.xxOpt');
x_admm = cell2mat(x);
e_xopt = abs(x_alex-x_admm); % percent

%% plot result
t_admm =  1:iter;
t_alex =  1:opts.maxIter;
subplot(2,1,1)
plot(t_alex, violation_alex, t_admm, violation_admm,'--');
grid on
xlabel('$\text{Iteration}$','interpreter','Latex');
ylabel('$||Ax-b||_{\infty}$ ','interpreter','Latex');
legend('ADMMnew from Alex','ADMM from Xinliang')
subplot(2,1,2)
bar(e_xopt)
xlabel('$\text{state}$','interpreter','Latex');
ylabel('$\text{state\quad error[abs]}$ ','interpreter','Latex');
