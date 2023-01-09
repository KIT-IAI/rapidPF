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
% casefile       = "118X3";
% casefile       = "418-10";
% casefile = '418-3';
% casefile = '118X8';
casefile = '118X10';
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
[lam0, xi, g_red, Hxx, Hyy, Hxy, H_red, Jr,x_idx, EE, Hi, Cx, Cy, gk, Jk, Hk] = deal(cell(Nregion,1));
[Nxi, Nyi, Nstate] = deal(zeros(Nregion,1));
% idx = logical(sparse(Nz,1),1));
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
%     problem.zz0{i} = 
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
% dx0 = norm(vertcat(xi{:})-xref)
iter_max = 6;
Nll      = size(problem.AA{1},1);
pn =[]
tic
% gauss newton test
for k = 1:iter_max
%     lam = lam0;

    for i = 1:Nregion
        if k >1
            g{i}    = gk{i};
            g{i}(x_idx{i}) = g{i}(x_idx{i})+lam{i};
%             pn{i} = - (Bk{i}+rho*speye(Nstate(i)))\g{i};
             pn{i}   = - Hk{i}\g{i};
            xi{i} = xi{i} + pn{i};
            
%             xi{i}(x_idx{i}) = xi{i}(x_idx{i}) + p_red{i};
        end
        [gk{i}, Jk{i}, Hk{i}] =   sens{i}(xi{i});
        Hk{i} = Hk{i}+ rho*speye(Nstate(i)); %+ rho*speye(Nstate(i));
        % reduced Hessian
        Jx = Jk{i} * Cx{i}';%Jx     = Jk{i}(:,x_idx{i});
        Jy = Jk{i} * Cy{i}';
        %gx     = gk{i}(x_idx{i});
        %gy     = gk{i}(~x_idx{i});
        gx{i} = Cx{i} * gk{i};
        gy{i} = Cy{i} * gk{i};
        Hxx{i}     = Jx'*Jx+reg*speye(Nxi(i));
        Hyy{i}     = Jy'*Jy+reg*speye(Nyi(i));
%         invHyy     = inv(full(Hyy{i}));
        Hxy{i}     = Jx'*Jy;
        H_red{i}   = Hxx{i} - Hxy{i}* (Hyy{i}\Hxy{i}');
        g_red{i}   = gx{i} - Hxy{i}*(Hyy{i}\gy{i});

    % QP subproblem - HDQ
%             g{i}    = gk{i};
%             g{i}(x_idx{i}) = g{i}(x_idx{i})+lam0{i};
%             pn{i} = - (Bk{i}+rho*speye(Nstate(i)))\g{i};
%             pn{i}     = - Hk{i}\g{i};
            p_red  = - H_red{i}\(g_red{i}+lam0{i});
%             x_plus{i} = pn{i}(x_idx{i}) + xi{i}(x_idx{i});
%             local_error = norm(pn{i}(x_idx{i})-p_red)
            x_plus{i} = p_red + xi{i}(x_idx{i});
        end
        H = blkdiag(H_red{:});
        X_plus = vertcat(x_plus{:});
%         Z_plus = pinv(full(E'*H*E))*(E'*(H*X_plus));
        Z_plus = ((E'*H*E))\(E'*(H*X_plus));
%         pp_local(n) = norm(vertcat(pn{:}));
        P = E*Z_plus  - X_plus;
%         dpnorm(n) = norm(P);
        v = vertcat(lam0{:}) - 10*H*(P);
%         v_norm(n) = norm(v);
        lam = distributed_states(v,lam0);
        p_red = distributed_states(P,x_plus);

%             px  = - H_red{i}\(g_red{i}+lam{i});
%             py  = - Hyy{i}\(Hxy{i}'*px+gy{i});
%             pp =p;
%             pp(x_idx{i}) = px
%             pp(~x_idx{i}) = py
%             pn{i} = p;
%     figure(3)
%     subplot(1,2,1)
%     semilogy(dpnorm)
%     title('dpnorm')
%     subplot(1,2,2)
%     semilogy(v_norm)
%     title('v_norm')
%       
      if k >1
        dx(k-1) = norm(vertcat(xi{:}) + vertcat(pn{:})- xref);
      end
%         dx(k)   
        norm_coupling(k) =   norm(P) ;
%     rho = max(rho/10,1e-9);
%     rho = max(norm_coupling(k)/10,1e-10);

end
toc
for i = 1:Nregion
    g{i}    = gk{i};
    g{i}(x_idx{i}) = g{i}(x_idx{i})+lam{i};
    %             pn{i} = - (Bk{i}+rho*speye(Nstate(i)))\g{i};
    pn{i}   = - Hk{i}\g{i};
end
dx(k) = norm(vertcat(xi{:}) + vertcat(pn{:})- xref);

figure(4)
subplot(1,2,1)
semilogy(norm_coupling)
title('norm_coupling')
subplot(1,2,2)
semilogy(dx)
title('dx')

function xi = distributed_states(X,xi)
    nstart = 0;
    for i = 1:numel(xi)
        nx = numel(xi{i});
        xi{i} = X((1:nx)+nstart);
        nstart = nstart+nx;
    end
end

