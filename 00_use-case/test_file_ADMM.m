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
%% ADMM test
clc
params.max_iter = 50;
params.tol = 0.01;
params.rou = 1000;
[x,e_admm] = solve_distributed_problem_with_ADMM(problem, params);

%% alex code
opts.scaling = false;
opts.rho = 1000;
opts.maxIter = 50;
opts.rhoUpdate = false;
solADM = run_ADMMnew(problem,opts);

% terminate condition check
A  = horzcat(problem.AA{:});
e_alex  = [];
for i = 1:opts.maxIter
    e_alex(i) = norm(A*solADM.logg.X(:,i),1);
end

%% compare the x_opt
x_alex = cell2mat(solADM.xxOpt');
x_admm = cell2mat(x);
e_xopt = abs(x_alex-x_admm); % percent

%% plot result
t =  1:opts.maxIter;
subplot(2,1,1)
plot(t, e_alex,t, e_admm,'--');
grid on
xlabel('$Iteration$','interpreter','Latex');
ylabel('$||Ax-b||_1$ ','interpreter','Latex');
legend('ADMMnew from Alex','ADMM from Xinliang')
subplot(2,1,2)
bar(e_xopt)
xlabel('$state$','interpreter','Latex');
ylabel('$state\quad error [%] $ ','interpreter','Latex');
