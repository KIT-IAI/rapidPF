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
casefile       = "118X3";
% casefile       = "418-10";

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
% mpc_merge = runpf(mpc_merge);
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
xref = vertcat(xsol_stacked{:});
% problem.solver      = 'worhp';
% problem.solver = 'fmincon';
% problem.solver = 'fminunc';
%problem.solver = 'Casadi+Ipopt';
%% modify formulation for HDQ
% incidence matrix
Nregion = numel(problem.AA); 
Nz      = size(problem.AA{1},1);
[lam0, xi, Hyy, Hyx, Jr,x_idx, EE, Hi] = deal(cell(Nregion,1));
[Nxi, Nstate] = deal(zeros(Nregion,1));
% idx = logical(sparse(Nz,1),1));
for i = 1:Nregion
    [row, col] = find(problem.AA{i});
    % number of coupling state
    Nxi(i)     = numel(row);
    Nstate(i)  = size(problem.AA{i},2);
    % idx for coupling state from total state
    x_idx{i}   = logical(sparse(Nstate(i),1));
    x_idx{i}(col) = true;
    EE{i}      = sparse(1:Nxi(i), row, ones(Nxi(i),1), Nxi(i), Nz);
    lam0{i}    = sparse(Nxi(i),1);
%     problem.zz0{i} = 
end
E = vertcat(EE{:});
D = E'*E;
%% initial
v0 = cell(Nregion,1);
yi = problem.zz0;
lam = lam0;
flag = false;
k = 1;
reg = 1e-8;
rho = 1;
dx = norm(vertcat(yi{:})-xref)
while k<40 && ~false
    for i = 1:Nregion
        % step 1: local step

        [grad, ~, hess] =   problem.sens{i}(yi{i});
        grad(x_idx{i})     =   grad(x_idx{i}) + lam{i};
        yi{i} = yi{i} - (hess+rho*speye(Nstate(i)))\ grad;
        xi{i} = yi{i}(x_idx{i});
        [Jr{i}, J,~] =   problem.sens{i}(yi{i});
        Jx     = J(:,x_idx{i});
        Jy     = J(:,~x_idx{i});
        Hxx    = Jx'*Jx;
        % regularization if low rank
%         if rank(full(Hxx))<Nxi(i) || min(eig(full(Hxx)))<0
            Hxx = Hxx + reg*speye(Nxi(i));
%         end
         Hyy{i}    = Jy'*Jy;
%         if rank(full(Hyy))<(Nstate(i)-Nxi(i)) || min(eig(full(Hyy)))<0
             Hyy{i} =  Hyy{i} + reg*speye(Nstate(i)-Nxi(i));
%         end
        Hyx{i}    = Jy'*Jx;
%         Hi     = Hxx - Hxy*inv(Hyy)*Hxy';
        invHy  = inv( Hyy{i});
        invHy  = (invHy+invHy')/2;
        Hi{i}   = Hxx - Hyx{i}'*invHy*Hyx{i};
%         size(Hi{i},1)
%         rank(full(Hi{i}))
    end
    dy = norm(vertcat(yi{:})-xref)
    H = blkdiag(Hi{:});
%     rank(full(H))
    X = vertcat(xi{:});
    z = (E'*H*E)\E'*H*X;
    Px = E*z - X;
    v = vertcat(lam{:}) - H*(Px) ;
    k = k+1
    lam = distributed_states(v,lam);
    pxi = distributed_states(Px,xi);
%     if k>1
    for i = 1:Nregion
        pyi = - Hyy{i}\(Jr{i}(~x_idx{i})+Hyx{i}*pxi{i});
        yi{i}(x_idx{i}) = yi{i}(x_idx{i})+pxi{i};
        yi{i}(~x_idx{i}) = yi{i}(~x_idx{i})+pyi;
    end
    dx = norm(vertcat(yi{:})-xref)
    rho = norm(Px)/10;
%     if k ==14
%         keyboard
%     end
%     end
end


function xi = distributed_states(X,xi)
    nstart = 0;
    for i = 1:numel(xi)
        nx = numel(xi{i});
        xi{i} = X((1:nx)+nstart);
        nstart = nstart+nx;
    end
end






























