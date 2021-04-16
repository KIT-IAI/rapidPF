clc
clear
close all;
load matlab.mat
import casadi.*
mu           = obj.logg.mu(k);
rho          = obj.logg.rho(k);
y0           = obj.logg.Y(:,k);

%% QP
options.ipopt.tol         = 1.0e-10;
options.ipopt.print_level = 5;
options.print_time        = 5;
options.ipopt.max_iter    = 100;
options.ipopt.constr_viol_tol = 1e-10;
Hk    = blkdiag(sensitivities(:).Hess,speye(obj.Nlam)*mu);
gk           = vertcat(sensitivities(:).grad,lam);
%                 Hk    = blkdiag(sensitivities(:).Hess);
%                 gk           = vertcat(sensitivities(:).grad);
% jacobian of constraint
C            = blkdiag(sensitivities(:).jacobian);  
Ncon         = size(C,1);     % number of constraints
% Aeq = | A   -I |    beq = | -A*y |
%       | C    0 |          |  0   | 
Aeq          = [obj.A, -speye(obj.Nlam);
                C,     sparse(Ncon,obj.Nlam)];
beq          = sparse(1:obj.Nlam,1,-obj.A*y0,obj.Nlam+Ncon,1);
qp = {};
K = conic('K','qpoases',qp);
r = K('h',Hk,'g',gk,'a',Aeq,'lba',beq,'uba',beq)

%% ipopt
options.ipopt.tol         = 1.0e-10;
options.ipopt.print_level = 0;
options.print_time        = 5;
options.ipopt.max_iter    = 100;
options.ipopt.constr_viol_tol = 1e-10;
mu           = obj.logg.mu(k);
rho          = obj.logg.rho(k);
y0           = obj.logg.Y(:,k);
dx_SX = SX.sym('dx',obj.Nx,1);
s_SX  = SX.sym('dx',obj.Nlam,1);
% extended variable - X = [dx; s]
X_SX  = vertcat(dx_SX,s_SX);        
% Hk = | Hi  0    |  gk = | grad | 
%      | 0   mu*I |       | lam  |
Hk    = blkdiag(sensitivities(:).Hess,speye(obj.Nlam)*mu);
gk           = vertcat(sensitivities(:).grad,lam);
%                 Hk    = blkdiag(sensitivities(:).Hess);
%                 gk           = vertcat(sensitivities(:).grad);
objective_fun =   X_SX'*Hk*X_SX/2 + gk'*X_SX;
% jacobian of constraint
C            = blkdiag(sensitivities(:).jacobian);  
Ncon         = size(C,1);     % number of constraints
% Aeq = | A   -I |    beq = | -A*y |
%       | C    0 |          |  0   | 
Aeq          = [obj.A, -speye(obj.Nlam);
                C,     sparse(Ncon,obj.Nlam)];
beq          = sparse(1:obj.Nlam,1,-obj.A*y0,obj.Nlam+Ncon,1);
con_fun      =   Aeq*X_SX - beq;

%                 lbx          = vertcat(sensitivities(:).lbdy);
%                 ubx          = vertcat(sensitivities(:).ubdy);                 
%                 
%                 feasible_region = ubx-lbx;
%                 feasible_region = feasible_region(isfinite(feasible_region));
%                 feasble_norm = norm(feasible_region,inf);
%                 ratio        = obj.logg.local_steplength(k)/feasble_norm;
%                 lbx = lbx*ratio;
%                 ubx = ubx*ratio;
if obj.logg.local_steplength(k)<=1e-4
    ratio = 0;
else
    ratio = obj.logg.local_steplength(k)/obj.logg.mu(k);
end
lbx          = vertcat(sensitivities(:).lbdy,-ratio*ones(obj.Nlam,1));
ubx          = vertcat(sensitivities(:).ubdy,ratio*ones(obj.Nlam,1)); 
nlp_casadi           = struct('x',X_SX,'f',objective_fun,'g',con_fun);
k1 = toc
tic
S             = nlpsol('solver','ipopt',nlp_casadi,options);
k2 = toc
X0 = vertcat(y0,zeros(obj.Nlam,1));
tic
sol = S('x0',   X0,...
                           'lbx',  lbx,...
                           'ubx',  ubx,...
                           'lbg',  zeros((Ncon+obj.Nlam),1),...
                           'ubg',  zeros((Ncon+obj.Nlam),1));
                       k3 = toc
xopt = full(sol.x);
dy = xopt(1:obj.Nx);
%                 dlam =  xopt((obj.Nx+1):end)*mu;
dlam = full(sol.lam_g(1:obj.Nlam))-lam;
kappa = full(sol.lam_g(obj.Nlam+1:end));