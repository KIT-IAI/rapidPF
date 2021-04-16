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
addpath(genpath('../04_solver_extension'));
%% idx info
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
% solver         = 'fmincon';
solver = 'casadi'

%% setup
names                = generate_name_struct();
matpower_casefile    = mpc_data(casefile);
[mpc_trans,mpc_dist] = gen_shift_key(matpower_casefile, gsk); % P = P * 0.2
mpc_trans.branch(:,[RATE_A,RATE_B,RATE_C]) = 0;
mpc_dist{1}.branch(:,[RATE_A,RATE_B,RATE_C]) = 0;
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
%% case-file-splitter
mpc_split = run_case_file_splitter(mpc_merge, conn, names);

%% interfacing rapidOPF - ALADIN OOP
% nlp = generate_opf_for_aladin(mpc_split, names);

mpc = mpc_split;

[N_regions, N_buses_in_regions, N_copy_buses_in_regions, ~] = get_relevant_information(mpc_split, names);
    connection_table = mpc.(names.consensus);

%% region 1
Nregion = numel(mpc.split_case_files);
% initialize local NLP problem by extracting data from rapidPF problem
nlps(Nregion,1)     = localNLP;
Nx_in_regions       = zeros(Nregion,1);
Nbus_in_regions    = zeros(Nregion,1);

for i = 1:Nregion
    mpc_local = mpc_split.split_case_files{i};

    %% create state variable - core bus and copy bus
    Nbus                =   numel(mpc_local.connections_with_aux_nodes);
    copy_bus_entries    =   mpc_local.copy_buses_local;
    Ncopy               =   numel(copy_bus_entries);
    % copy bus always at the end
    % core = gen + net
    Ncore               =   numel(mpc_local.regions);
    core_bus_entries    =   1:Ncore;
    gen_idx             =   ismember(mpc_local.regions,mpc_local.gen(:,GEN_BUS));
    gen_bus_entries     =   find(gen_idx);     % entries of bus data
    gen_bus_global      =   mpc_local.bus(gen_bus_entries,GEN_BUS);

    core_gen_entries    =   find(ismember(mpc_local.gen(:,GEN_BUS),mpc_local.bus(gen_bus_entries,BUS_I)));  % entries of gen data
    load_bus_entries    =   find(~gen_idx);
    Nload               =   numel(load_bus_entries);
    Ngen                =   numel(gen_bus_entries);

    % 
    [Vang_load, Vmag_load, Pnet_load, Qnet_load] = create_state('_net', Nload);
    [Vang_gen, Vmag_gen, Pnet_gen, Qnet_gen]     = create_state('_gen', Ngen);
    [Vang_copy, Vmag_copy, Pnet_copy, Qnet_copy] = create_state('_copy', Ncopy);

    Vang = [Vang_gen; Vang_load; Vang_copy];
    Vmag = [Vmag_gen; Vmag_load; Vmag_copy];

    Pg   = Pnet_gen;
    Qg   = Qnet_gen;

    local_state = stack_state(Vang, Vmag, Pg, Qg);
    Nx          = Nbus*2 + Ngen*2;
    %% extract local grid model 

    baseMVA          =   mpc_local.baseMVA;              % baseMVA
    genNodes         =   mpc_local.gen(core_gen_entries,GEN_BUS);       % 发电机的bus
    % gencost haven't been splitted - complicated - need to be simplified
    gencost_idx_global = find(ismember(mpc.gen(:,GEN_BUS), gen_bus_global));
    genCost          =   mpc.gencost(gencost_idx_global,5:end);          % objective coefficients

    Pgmin            =   mpc_local.gen(core_gen_entries,PMIN)/baseMVA;
    Qgmin            =   mpc_local.gen(core_gen_entries,QMIN)/baseMVA;
    Pgmax            =   mpc_local.gen(core_gen_entries,PMAX)/baseMVA;
    Qgmax            =   mpc_local.gen(core_gen_entries,QMAX)/baseMVA;

    Pd               =   mpc_local.bus(:,PD)/baseMVA;   
    Qd               =   mpc_local.bus(:,QD)/baseMVA;  
    %% lower & upper bounds
    lbx{i}         = [-pi*ones(Nbus,1);mpc_local.bus(:,VMIN);Pgmin;Qgmin];       
    ubx{i}        =  [ pi*ones(Nbus,1);mpc_local.bus(:,VMAX);Pgmax;Qgmax];
    %% initial x0
% % 
%     Vang0 = mpc_local.bus(:,VA)/180*pi;
%     Vmag0 = mpc_local.bus(:,VM);
% %     gencost haven't been splitted - complicated - need to be simplified
%     Pg0   = mpc.gen(gencost_idx_global,PG)/baseMVA;
%     Qg0   = mpc.gen(gencost_idx_global,QG)/baseMVA;
%     xsol{i} = stack_state(Vang0,Vmag0,Pg0,Qg0);
% 
    Vang0 = mpc_local.bus(:,VA)/180*pi;
    Vmag0 = mpc_local.bus(:,VM);
%     gencost haven't been splitted - complicated - need to be simplified
    Pg0   = mpc.gen(gencost_idx_global,PG)/baseMVA;
    Qg0   = mpc.gen(gencost_idx_global,QG)/baseMVA;
    

    x0{i}    =  stack_state(Vang0,Vmag0,Pg0,Qg0);

%     x0{i}<=ubx{i}
%     x0{i}>=lbx{i}
    %% equality constraints - current balance constraints
    Ybus             =   makeYbus(ext2int(mpc_local));
    entries_pf{1}    =   1:Nbus;                   % Vang
    entries_pf{2}    =   (Nbus+1):2*Nbus;          % Vmag
    entries_pf{3}    =   (2*Nbus+1):(2*Nbus+Ngen);      % Pg
    entries_pf{4}    =   (2*Nbus+Ngen+1):2*(Nbus+Ngen); % Qg
    pf_p             =   @(x)create_local_power_flow_equation_p(x(entries_pf{1}),...
        x(entries_pf{2}), x(entries_pf{3}), Ybus,gen_bus_entries,copy_bus_entries,Pd);
    pf_q             =   @(x)create_local_power_flow_equation_q(x(entries_pf{1}),...
        x(entries_pf{2}), x(entries_pf{4}), Ybus,gen_bus_entries,copy_bus_entries,Qd);
    % slack
    slack_bus_entries =  find(mpc_local.bus(:,BUS_TYPE) == REF);

    %% jacobian
    Jac_pf  = @(x)jacobian_power_flow_modified(x(entries_pf{1}), x(entries_pf{2}), x(entries_pf{3}), x(entries_pf{4}), Ybus, gen_bus_entries,copy_bus_entries);


    %% cost function - for quadratic gencost
    fi{i}           =@(x) (baseMVA^2*x(entries_pf{3})'*diag(genCost(:,1))*x(entries_pf{3})...
                  + baseMVA*x(entries_pf{3})'*genCost(:,2))/baseMVA;
    %% gradient

    gi{i}           = @(x)[zeros(2*Nbus,1); baseMVA^2*2*diag(genCost(:,1))*x(entries_pf{3})+baseMVA*genCost(:,2);zeros(Ngen,1)];
    %% hessian of lagrangian multiplier
    mpc_local;
    copy_gen_data = ~ismember(mpc_local.gen(:,GEN_BUS), mpc_local.regions);

    mpc_local.gen(copy_gen_data,:) = [];
    mpc_local.gen(1:Ngen,GEN_BUS) = gen_bus_entries';
    lambda = ones(2*Ncore,1);

    hi_pf         = @(x,kappa) blkdiag(sparse(2*Nbus,2*Nbus),baseMVA^2*2*diag(genCost(:,1)),sparse(Ngen,Ngen)) ... 
        + opf_hess_current_balance_modified(x,entries_pf,kappa,Ncopy,mpc_local,Ybus,mpoption);
    %% slack
    if ~isempty(slack_bus_entries)
        gslack   =  @(x) x(slack_bus_entries);
        con_eq{i}   = @(x) [pf_p(x);pf_q(x);gslack(x)];
        jac_eq{i}    = @(x)[Jac_pf(x);sparse(1,1,1,1,Nx)];
    else
        con_eq{i}               = @(x) [pf_p(x);pf_q(x)];
        jac_eq{i}    =  @(x)Jac_pf(x);   
    end
    hi{i}       = @(x,kappa)hi_pf(x,kappa);
    % size(x0)
    % size(con_eq{i}(x0{i}))
    % size(jac_eq{i}(x0{i}))
    % size(hi{i}(x0{i},lambda))

    
    Nx_in_regions(i) = Nx;
    Nbus_in_regions(i) = Nbus;
end

AA  = create_consensus_matrices_modified(connection_table, Nx_in_regions, Nbus_in_regions);
%% initialize ALADIN oop
%     lbx{i}         = [];% [-pi*ones(Nbus,1);mpc_local.bus(:,VMIN);Pgmin;Qgmin];       
%     ubx{i}        =  [];%[ pi*ones(Nbus,1);mpc_local.bus(:,VMAX);Pgmax;Qgmax];
A   = horzcat(AA{:});
grad_global = vertcat(gi{1}(x0{1}),gi{2}(x0{2}));
% lam0 = lsqminnorm(A', -grad_global)

lam0 = ones(size(A,1),1)*0.1;
% lam0 = [-1.44158834988213;-1.44158834988213;0.00909003355743966;0.0522883023756992];
b    = zeros(size(A,1),1);
option           = AladinOption;
option.problem_type = problem_type;
option.iter_max  = 15;
option.tol       = 1e-8;
option.mu0       = 1e3;
option.rho0      = 1e4;
option.nlp       = NLPoption;
option.nlp.solver = solver;
option.nlp.iter_display = true;
option.qp        = QPoption;
% option.qp.regularization_hess = true;
% option.qp.solver = 'lsqminnorm';
% option.qp.solver = 'lsqlin';
option.qp.solver = 'casadi';


for i = 1:Nregion
	local_funs = originalFuns(fi{i}, gi{i}, hi{i}, AA{i}, [], [], con_eq{i}, jac_eq{i}, [], []);
    nlps(i)    = localNLP(local_funs,option.nlp,lbx{i},ubx{i});
end
[xopt,logg] = run_aladin_algorithm(nlps,x0,lam0,A,b,option); 
%% validationg
opts = mpoption;

opts.opf.violation = 1e-12;
mpc_merge = runopf(mpc_merge,opts);
% initialize local NLP problem by extracting data from rapidPF problem
nlps(Nregion,1)     = localNLP;
mpc_split = run_case_file_splitter(mpc_merge, conn, names);
mpc = mpc_split;


for i = 1:Nregion
    mpc_local = mpc_split.split_case_files{i};
    gen_idx             =   ismember(mpc_local.regions,mpc_local.gen(:,GEN_BUS));
    gen_bus_entries     =   find(gen_idx);     % entries of bus data

    gen_bus_global      =   mpc_local.bus(gen_bus_entries,GEN_BUS);
    gencost_idx_global = find(ismember(mpc.gen(:,GEN_BUS), gen_bus_global));
    Vang_opt = mpc_local.bus(:,VA)/180*pi;
    Vmag_opt = mpc_local.bus(:,VM);
%     gencost haven't been splitted - complicated - need to be simplified
    Pg_opt   = mpc.gen(gencost_idx_global,PG)/baseMVA;
    Qg_opt   = mpc.gen(gencost_idx_global,QG)/baseMVA;
    xsol{i} = stack_state(Vang_opt,Vmag_opt,Pg_opt,Qg_opt);
end
XOPT = vertcat(xsol{:});
logg.plot_distance(XOPT);
dx = norm(xopt-XOPT,inf)
% res = runopf(mpc);

% 
% 
% 
% 
% % 
% 
% 
% %% numbering 
% 
% % N_gen            =   
% 
% %% create state variable - core bus and copy bus
% [Vang_core, Vmag_core, Pnet_core, Qnet_core] = create_state(postfix, N_core);
% [Vang_copy, Vmag_copy, Pnet_copy, Qnet_copy] = create_state(strcat(postfix, '_copy'), N_copy);
% 
% Vang             =   [Vang_core; Vang_copy];
% Vmag             =   [Vmag_core; Vmag_copy];
% Pnet             =   Pnet_core;
% Qnet             =   Qnet_core;
% P                =   [Pnet_core; Pnet_copy];
% Q                =   [Qnet_core; Qnet_copy];
% % dont need Pnet, Qnet to create power flow equation
% state = stack_state(Vang, Vmag, Pnet, Qnet);
% %% create power flow equation
% entries_pf       =   build_entries(N_core, N_copy, true);
% pf_p             =   @(x)create_power_flow_equation_for_p(x(entries_pf{1}), x(entries_pf{2}), x(entries_pf{3}), x(entries_pf{4}), Ybus, buses_local);
% pf_q             =   @(x)create_power_flow_equation_for_q(x(entries_pf{1}), x(entries_pf{2}), x(entries_pf{3}), x(entries_pf{4}), Ybus, buses_local);
% 
% 
% 
% %% Set up Matrices
% Y_bus           =   full(makeYbus(mpc));      % resistance matrix
% 
% N               =   size(Y_bus,1);            % numb of bus   
% Ngen            =   length(genNodes);         % numb of generator (one bus might have several generators)
% Nlines          =   size(mpc.branch,1);       % numb of line
% 
% Adj             =   abs(Y_bus) > 0;           % adjoint matrix of grid
% 
% 
% 
% %% validation
% % res   = runopf(mpc);
% % dVm   = norm(res.bus(:,VM) - Vopt,2);
% % dVang = norm(res.bus(:,VA)/180*pi - thetaOpt,2);
% % dPg   = norm(res.gen(:,PG)/baseMVA - Pgopt,2);
% % dQg   = norm(res.gen(:,QG)/baseMVA - Qgopt,2);
% % table(dVm,dVang,dPg,dQg)
