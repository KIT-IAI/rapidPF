clc
clear
close all

addpath(genpath('../00_use-case/'));
addpath(genpath('../01_generator/'));
addpath(genpath('../02_splitter/'));
addpath(genpath('../03_parser/'));
addpath(genpath('../04_solver_extension'));


%% plot option
% [options, app] = plot_options;
% casefile       = options.casefile;
% gsk            = options.gsk;      % generation shift key
% problem_type   = options.problem_type;
% algorithm      = options.algorithm;
% solver         = options.solver;


casefile       = 'test';
gsk            = 0;      % generation shift key
problem_type   = 'least-squares';
algorithm      = 'aladin';
solver         = 'fmincon';

% setup
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
% idx info
% bus idx
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
% branch idx
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
% gen idx
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
% cost idx
[PW_LINEAR, POLYNOMIAL, MODEL, STARTUP, SHUTDOWN, NCOST, COST] = idx_cost;%% build opf problem

% main
% case-file-generator
mpc_merge = run_case_file_generator(mpc_trans, mpc_dist, conn, fields_to_merge, names);

% case-file-splitter
mpc_split = run_case_file_splitter(mpc_merge, conn, names);
%%
import casadi.*

% Define the problem
caseFile        =   mpc_merge;

% Extract Data from MATPOWER casefile
mpc             =   loadcase(caseFile);
baseMVA         =   mpc.baseMVA;              % 功率缩放
genNodes        =   mpc.gen(:,1);             % 发电机的bus
genCost         =   mpc.gencost(:,5:end);     % objective coefficients

Pgmin           =   mpc.gen(:,10)/baseMVA;
Qgmin           =   mpc.gen(:,5)/baseMVA;
Pgmax           =   mpc.gen(:,9)/baseMVA;
Qgmax           =   mpc.gen(:,4)/baseMVA;

Pdnum           =   mpc.bus(:,3)/baseMVA;   
Qdnum           =   mpc.bus(:,4)/baseMVA;   

% Set up Matrices
Y_bus           =   full(makeYbus(mpc));      % resistance matrix

N               =   size(Y_bus,1);            % numb of bus   
Ngen            =   length(genNodes);         % numb of generator (one bus might have several generators)
Nlines          =   size(mpc.branch,1);       % numb of line

Adj             =   abs(Y_bus) > 0;           % adjoint matrix of grid

% define problem
% symbolic states
theta   =   SX.sym('theta',N,1);
V       =   SX.sym('V',N,1);
Pg      =   SX.sym('Pg',Ngen,1);
Qg      =   SX.sym('Qg',Ngen,1);

x       =   [theta;V;Pg;Qg];   
nx      =   length(x);

% Generate the cost and constraint functions 
[gP, gQ]    = createPFeq(x,Y_bus,Ngen,genNodes,Pdnum,Qdnum);

% cost function
f           = baseMVA^2*Pg'*diag(genCost(:,1))*Pg...
              + baseMVA*Pg'*genCost(:,2);
grad        = baseMVA^2*2*diag(genCost(:,1))*Pg + baseMVA*genCost(:,2);
% constraint
% find reference bus
index = find(mpc.bus(:,2)==3); 

gslack  = [theta(mpc.bus(index,1))-0];
           %V(mpc.bus(index,1))-1];        % reference bus: theta=0 ];        % reference bus: theta=0
g       = [gP;gQ;gslack];   
gdim    = length(g);

%gfun        = Function('gfun',{x},{g});
%ffun        = Function('ffun',{x},{f});

% box constraint from matpower
% Vmax: mpc.bus(:,13) Vmin: mpc.bus(:,12)

lbx         = [-inf*ones(N,1);mpc.bus(:,13);Pgmin;Qgmin];       
ubx         = [inf*ones(N,1);mpc.bus(:,12);Pgmax;Qgmax];


x0          = [zeros(N,1);ones(N,1);mpc.gen(:,2);mpc.gen(:,3)];
%res         = runopf(caseFile);
[xopt,fval] = solveNLP(f,grad,g,x,gdim,lbx,ubx,x0);

% display the solution
thetaOpt    = xopt(1:N);
Vopt        = xopt((N+1):2*N);
Pgopt       = xopt(2*N+1:2*N+Ngen);
Qgopt       = xopt(2*N+Ngen+1:end);
table(thetaOpt,Vopt)
table(Pgopt,Qgopt)
% validation
res   = runopf(mpc);
dVm   = norm(res.bus(:,VM) - Vopt,2);
dVang = norm(res.bus(:,VA)/180*pi - thetaOpt,2);
dPg   = norm(res.gen(:,PG)/baseMVA - Pgopt,2);
dQg   = norm(res.gen(:,QG)/baseMVA - Qgopt,2);
table(dVm,dVang,dPg,dQg)
function [xopt,fval] = solveNLP(ffun,fgrad,gfun,x,gdim,lbx,ubx,x0)
    import casadi.*
    nlp = struct('x',x,'f',ffun,'g',gfun);
    options.ipopt.tol         = 1.0e-8;
    options.ipopt.print_level = 5;
%     options.ipopt.grad_f = fgrad;
    options.print_time        = 5;
    options.ipopt.max_iter    = 100;
    S = nlpsol('solver','ipopt', nlp,options);
    sol = S('x0', x0,'lbg', zeros(gdim,1),'ubg', zeros(gdim,1),...
            'lbx', lbx, 'ubx', ubx);
    xopt = full(sol.x);
    fval = full(sol.f);
end

