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
% %% plot option
% [options, app] = plot_options;
% casefile       = options.casefile;
%%
% gsk            = 0;options.gsk;      % generation shift key
% problem_type   = options.problem_type;
% algorithm      = options.algorithm;
% solver         = options.solver;
gsk            = 0;
problem_type   = 'least-squares';
algorithm      = 'aladin';
solver         = 'fmincon';
% casefile       = "53-II";
% load xref_53.mat
% casefile       = "118X3";
% casefile       = "418-5";
% casefile = '418-3';
% load xref_418.mat
% casefile = '118X8';
casefile = '118X10';
load xref_118_10.mat

% casefile = '2708-1';
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
% opts = mpoption;
% opts.opf.violation = 1e-12;
% opts.mips.costtol = 1e-12;
% opts.mips.gradtol= 1e-12;
% opts.mips.comptol= 1e-12;
% opts.opf.ignore_angle_lim = true;
% mpc_merge = runpf(mpc_merge,opts);
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

option              = AladinOption;
option.problem_type = problem_type;
option.iter_max  = 5;
option.tol       = 1e-6;
option.mu0       = 1e2;
option.rho0      = 1e2;
option.nlp       = NLPoption;
% option.nlp.solver = 'mldivide'; %solver;
% option.nlp.solver = 'cg_steihaug';
option.nlp.solver = 'mldivide';
% option.nlp.solver = 'MA57';
% option.nlp.solver = 'casadi';
option.nlp.iter_display = false;
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
% logg.computing_time
% 
xref = vertcat(xsol_stacked{:});
% problem.solver      = 'worhp';
% problem.solver = 'fmincon';
% problem.solver = 'fminunc';
%problem.solver = 'Casadi+Ipopt';
%% modify formulation for HDQ
% incidence matrix
Nregion = numel(problem.AA); 
Nz      = size(problem.AA{1},1);
[lam0, xi, x_plus, p_recover, pn, g_red, gx, gy, Hxx, Hyy, Hxy, H_red, Jr,x_idx, EE, Hi, Cx, Cy, gk, Jk, Hk] = deal(cell(Nregion,1));
[Nxi, Nyi, Nstate] = deal(zeros(Nregion,1));
% idx = logical(sparse(Nz,1),1));
import casadi.*
for i = 1:Nregion
    [row, col_x] = find(problem.AA{i});
    % number of coupling state
    Nxi(i)     = numel(row);
    Nstate(i)  = size(problem.AA{i},2);
    Nyi(i)     = Nstate(i) - Nxi(i);
    % idx for coupling state from total state
    x_idx{i}   = logical(sparse(Nstate(i),1));
    x_idx{i}(col_x) = true;
    col_y      = 1:Nstate(i);
    col_y(col_x) = [];
    EE{i}      = sparse(1:Nxi(i), row, ones(Nxi(i),1), Nxi(i), Nz);
    Cx{i}      = sparse(1:Nxi(i),col_x,ones(Nxi(i),1),Nxi(i),Nstate(i));
    Cy{i}      = sparse(1:Nyi(i),col_y,ones(Nyi(i),1),Nyi(i),Nstate(i));
    lam0{i}    = sparse(Nxi(i),1);
    Nxall      = size(problem.AA{i},2);
    Sigma{i}   = speye(Nxall);
    sens{i}    = problem.sens{i};
    xi_SX   = SX.sym('xi',Nstate(i),1);
    fi_SX   = problem.locFuns.ffi{i}(xi_SX);
    hess_casadi          = hessian(fi_SX,xi_SX);
    casadi_model{i}         = Function('sens',{xi_SX},{hess_casadi});
end
E = vertcat(EE{:});
D = E'*E;
%% initial
 % initial
v0 = cell(Nregion,1);
xi = problem.zz0;
flag = false;
reg = 1e-10;
rho = 1e-9;
dx0 = norm(vertcat(problem.zz0{:})-xref,2);
iter_max = 10;
Nll      = size(problem.AA{1},1);

%
logg_hdsqp.et.local  = zeros(Nregion,iter_max);
logg_hdsqp.et.global = zeros(iter_max,1);
logg_hdsqp.et.total  = zeros(iter_max,1);
dx                   = zeros(iter_max,1);
norm_coupling        = zeros(iter_max,1);
df                   = zeros(iter_max,1);
norm_lam             = zeros(iter_max,1);
norm_Q               = zeros(iter_max,1);
norm_dp              = zeros(iter_max,1);
norm_distance        = zeros(iter_max,1);
% gauss newton test
k                    = 1;
while (k <= iter_max) 
%     lam = lam0;
    for i = 1:Nregion
        tic
        if k >1
            g{i}    = gk{i};
            g{i}(x_idx{i}) = g{i}(x_idx{i})+lam{i};
            pn{i}   = - Hk{i}\g{i};
            xi{i}   = xi{i} + pn{i};
        end
        [gk{i}, Jk{i}, Hk{i}] =   sens{i}(xi{i});
%         size(Jk{i})
%         rank(full(Jk{i}))
        HH    = sparse(casadi_model{i}(xi{i}));
        QQ(i)    = norm(HH-Hk{i},inf);
        Hk{i} = Hk{i}+ rho*speye(Nstate(i)); %+ rho*speye(Nstate(i));
%         BQ = norm(Hk{i}\QQ,inf)

        % reduced Hessian
        Jx = Jk{i} * Cx{i}';%Jx     = Jk{i}(:,x_idx{i});
        Jy = Jk{i} * Cy{i}';

        
        gx{i} = Cx{i} * gk{i};
        gy{i} = Cy{i} * gk{i};
        Hxx{i}     = Jx'*Jx+reg*speye(Nxi(i));
        Hyy{i}     = Jy'*Jy+reg*speye(Nyi(i));
        Hxy{i}     = Jx'*Jy;
        H_red{i}   = Hxx{i} - Hxy{i}* (Hyy{i}\Hxy{i}');
        g_red{i}   = gx{i}  - Hxy{i}*(Hyy{i}\gy{i});
        % QP subproblem - HDQ
        p_red      = - H_red{i}\(g_red{i}+lam0{i});
        x_plus{i}  = p_red + xi{i}(x_idx{i});
        logg_hdsqp.et.local(i,k) = toc;
        % testing
        g{i}        = gk{i};
        g{i}(x_idx{i}) = g{i}(x_idx{i})+lam0{i};
        pn{i}       = - Hk{i}\g{i};
        dpx(i)       = norm(p_red - Cx{i} *pn{i},inf);

    end
    tic
    H = blkdiag(H_red{:});
    X_plus = vertcat(x_plus{:});
    Z_plus = ((E'*H*E))\(E'*(H*X_plus));
    P = E*Z_plus  - X_plus;
    v = vertcat(lam0{:}) - 10*H*(P);
%         v_norm(n) = norm(v);
    lam = distributed_states(v,lam0);
    logg_hdsqp.et.global(k) = toc;
    logg_hdsqp.et.total(k) = max(logg_hdsqp.et.local(:,k))+logg_hdsqp.et.global(k);
%      
    % test
%     for i = 1:Nregion
%         g{i}    = gk{i};
%         g{i}(x_idx{i}) = g{i}(x_idx{i})+lam{i};
%         pn{i}   = - Hk{i}\g{i};
%         px = - H_red{i}\(g_red{i}+lam{i});
%         py = - Hyy{i}\(Hxy{i}'*px+gy{i});
%         p_recover{i}= Cx{i}'*px + Cy{i}'*py;
%     end
%     dp(k) = norm(vertcat(p_recover{:})-vertcat(pn{:}),inf);
  if k >1
    x_dsqp(:,k-1) = vertcat(xi{:});

    for i = 1:Nregion
        df(k-1) = df(k-1) + problem.locFuns.ffi{i}(xi{i});
    end
  end
for i = 1:Nregion
    g{i}    = gk{i};
    g{i}(x_idx{i}) = g{i}(x_idx{i})+lam{i};
    pn{i}   = - Hk{i}\g{i};
    Xi{i}   = xi{i}(x_idx{i}) + pn{i}(x_idx{i});
end
    X_plus=vertcat(Xi{:});
    Z_plus = ((E'*H*E))\(E'*(H*X_plus));
    PP = E*Z_plus  - X_plus;
    norm_distance(k) = sqrt(PP'*H*PP);
    norm_coupling(k) = norm(PP,inf);
    norm_lam(k)      = norm(vertcat(lam{:}),inf);
    norm_Q(k)        = norm(QQ,inf);
    norm_dp(k)       = norm(dpx);
    rho              = max(1e-9, rho/100);
    k                = k+1;
end
logg_hdsqp.et.computing_time = sum(logg_hdsqp.et.total);
logg_hdsqp.et.computing_time
df0 = 0;
for i = 1:Nregion
    g{i}    = gk{i};
    g{i}(x_idx{i}) = g{i}(x_idx{i})+lam{i};
    %             pn{i} = - (Bk{i}+rho*speye(Nstate(i)))\g{i};
    xi{i}   = xi{i} - Hk{i}\g{i};
    df0   = problem.locFuns.ffi{i}(problem.zz0{i});
end
x_dsqp(:,k) = vertcat(xi{:});
% dx(k) = norm(vertcat(xi{:})- xref);
% time
t = zeros(iter_max,1);
dx_dsqp = zeros(iter_max,1);
for i=1:iter_max
    t(i) = sum(logg_hdsqp.et.total(1:i));
    dx_dsqp(i) = norm(x_dsqp(:,i) - xx0,inf);
end
t = [0;t];
dx_dsqp = [dx0;dx_dsqp];
df = [df0;df];
t_aladin = zeros(logg.iter,1);
dx_aladin = zeros(logg.iter,1);
for i = 1:logg.iter
    t_aladin(i)  = sum(logg.et.total(1:i));
    dx_aladin(i) = norm(logg.X(:,i) - xx0,inf);
    dfk          = 0
    for i = 1:Nregion
        df(k)      = df(k) + problem.locFuns.ffi{i}(xi{i});
    end
end
t_aladin = [0;t_aladin];
dx_aladin = [dx0;dx_aladin];
logg.delta = [df0;logg.delta];
figure(4)
% subplot(1,3,1)
% semilogy(t,norm_coupling,'x-')
title('norm_coupling')
subplot(1,2,1)
semilogy(t,dx_dsqp,'x-',t_aladin,dx_aladin,'x-')
title('dx')
subplot(1,2,2)
semilogy(t,df,'x-',t_aladin,logg.delta,'x-')
title('df')
size(vertcat(problem.zz0{:}))
size(vertcat(x_plus{:}))

function xi = distributed_states(X,xi)
    nstart = 0;
    for i = 1:numel(xi)
        nx = numel(xi{i});
        xi{i} = X((1:nx)+nstart);
        nstart = nstart+nx;
    end
end
