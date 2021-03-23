%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   this function use to solve local nlp (1st region)
%   in the first iteration, based on case14
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initial
clc
clear
close all

addpath(genpath('../01_generator/'));
addpath(genpath('../02_splitter/'));
addpath(genpath('../03_parser/'));
addpath(genpath('../04_solver_extension'));

% setup
names                = generate_name_struct();
matpower_casefile    = mpc_data('14+30+9');
[mpc_trans,mpc_dist] = gen_shift_key(matpower_casefile, 1); % P = P * 0.2
fields_to_merge      = matpower_casefile.fields_to_merge;
connection_array     = matpower_casefile.connection_array;

trafo_params.r = 0;
trafo_params.x = 0.00623;
trafo_params.b = 0;
trafo_params.ratio = 0.985;
trafo_params.angle = 0;

conn = build_connection_table(connection_array, trafo_params);
Nconnections = height(conn);
% case-file-generator
mpc_merge = run_case_file_generator(mpc_trans, mpc_dist, conn, fields_to_merge, names);
% case-file-splitter
mpc_split = run_case_file_splitter(mpc_merge, conn, names);
% generate distributed problem
problem_type = 'least-squares';
% problem_type = 'least-squares';
problem = generate_distributed_problem_for_aladin(mpc_split, names, problem_type);

%% start local nlp
x0 = [0;-0.0869173967493176;-0.222005880853679;-0.180292511731014;-0.153239908325102;-0.248185819633594;-0.233350520991642;-0.233175988066442;-0.260752190247953;-0.263544717051144;-0.258134196369961;-0.263021118275546;-0.264591914602340;-0.279950812019890;0;1.06000000000000;1.04500000000000;1.01000000000000;1.01900000000000;1.02000000000000;1.07000000000000;1.06200000000000;1.09000000000000;1.05600000000000;1.05100000000000;1.05700000000000;1.05500000000000;1.05000000000000;1.03600000000000;1;2.32400000000000;0.183000000000000;-0.942000000000000;-0.478000000000000;-0.0760000000000000;-0.112000000000000;0;0;-0.295000000000000;-0.0900000000000000;-0.0350000000000000;-0.0610000000000000;-0.135000000000000;-0.149000000000000;-0.169000000000000;0.297000000000000;0.0440000000000000;0.0390000000000000;-0.0160000000000000;0.0470000000000000;0;0.174000000000000;-0.166000000000000;-0.0580000000000000;-0.0180000000000000;-0.0160000000000000;-0.0580000000000000;-0.0500000000000000];
z  = [0;-0.0869173967493176;-0.222005880853679;-0.180292511731014;-0.153239908325102;-0.248185819633594;-0.233350520991642;-0.233175988066442;-0.260752190247953;-0.263544717051144;-0.258134196369961;-0.263021118275546;-0.264591914602340;-0.279950812019890;0;1.06000000000000;1.04500000000000;1.01000000000000;1.01900000000000;1.02000000000000;1.07000000000000;1.06200000000000;1.09000000000000;1.05600000000000;1.05100000000000;1.05700000000000;1.05500000000000;1.05000000000000;1.03600000000000;1;2.32400000000000;0.183000000000000;-0.942000000000000;-0.478000000000000;-0.0760000000000000;-0.112000000000000;0;0;-0.295000000000000;-0.0900000000000000;-0.0350000000000000;-0.0610000000000000;-0.135000000000000;-0.149000000000000;-0.169000000000000;0.297000000000000;0.0440000000000000;0.0390000000000000;-0.0160000000000000;0.0470000000000000;0;0.174000000000000;-0.166000000000000;-0.0580000000000000;-0.0180000000000000;-0.0160000000000000;-0.0580000000000000;-0.0500000000000000];
rho= 100;
lambda = [0.0100000000000000;0.0100000000000000;0.0100000000000000;0.0100000000000000;0.0100000000000000;0.0100000000000000;0.0100000000000000;0.0100000000000000;0.0100000000000000;0.0100000000000000;0.0100000000000000;0.0100000000000000];
Sigma = eye(58);
pars = [];
i=1;
lbx = problem.llbx;
ubx = problem.uubx;
funs = problem.locFuns;
sens = problem.sens;


%% fmincon
solve_nlp_fmincon = build_local_NLP_with_fmincon(funs.ffi{i}, funs.ggi{i}, funs.hhi{i}, problem.AA{i}, lambda, rho, z, Sigma, x0, problem.llbx{i}, problem.uubx{i}, sens.JJac{i}, sens.gg{i}, sens.HH{i});   
xfmin = solve_nlp_fmincon.x;

%% nonl
solve_nlp_fmincon = build_local_NLP_with_lsqnonlin(funs.rri{i}, funs.dri{i}, funs.hhi{i}, problem.AA{i}, lambda, rho, z, Sigma, x0, problem.llbx{i}, problem.uubx{i}, sens.JJac{i}, sens.gg{i}, sens.HH{i});   
xlsqnonlin = solve_nlp_fmincon.x;

%%
norm(xfmin - xlsqnonlin,1)
% g = funs.ggi{i};
% g(x1)
function res = build_local_NLP_with_fmincon(f, g, h, A, lambda, rho, z, Sigma, x0, lbx, ubx, dgdx, dfdx, Hessian)
    opts = optimoptions('fmincon');
    opts.Algorithm = 'interior-point';
    opts.CheckGradients = false;
    opts.SpecifyConstraintGradient = true;
    opts.SpecifyObjectiveGradient = true;
    opts.Display = 'iter';
    Nx  =  numel(x0);
    % select Hessian approximation
    if isempty(g(x0)) && isempty(h(x0)) 
%        unconstrained problem and Hessian is computed by hand
        opts.HessFcn = @(x,kappa)build_hessian(Hessian(x,0,0), zeros(Nx,Nx), rho, Sigma);
    else
        %% three method to approach hessian: BFGS, limit-memory BFGS, infinite jacobian 
%       opts.HessianApproximation = 'bfgs';
%       opts.HessianApproximation = 'lbfgs';
        opts.HessFcn = @(x,kappa)build_hessian(zeros(Nx,Nx), Hessian(x,kappa.eqnonlin,0), rho, Sigma);
    end
    objective    = @(x)build_objective(x, f(x), dfdx(x), [], lambda, A, rho, z, Sigma);
    nonlcon = @(x)build_nonlcon(x, g, h, dgdx);
    [xopt, fval, flag, out, multiplier] = fmincon(objective, x0, [], [], [], [], lbx, ubx, nonlcon, opts);
    res.x = xopt;
    res.lam_g = [multiplier.eqnonlin; multiplier.ineqnonlin];
    res.lam_x = max(multiplier.lower, multiplier.upper);
    res.pars = [];
end

function res = build_local_NLP_with_lsqnonlin(r, drdx, h, A, lambda, rho, z, Sigma, x0, lbx, ubx, dgdx, dfdx, Hessian)
%     opts = optimoptions('fmincon');
%     opts.Algorithm = 'interior-point';
%     opts.CheckGradients = false;
%     opts.SpecifyConstraintGradient = true;
%     opts.SpecifyObjectiveGradient = true;
%     opts.Display = 'iter';
    Nx  =  numel(x0);
    % select Hessian approximation
%     if isempty(g(x0)) && isempty(h(x0)) 
% %        unconstrained problem and Hessian is computed by hand
%         opts.HessFcn = @(x,kappa)build_hessian(Hessian(x,0,0), zeros(Nx,Nx), rho, Sigma);
%     else
        %% three method to approach hessian: BFGS, limit-memory BFGS, infinite jacobian 
%       opts.HessianApproximation = 'bfgs';
%       opts.HessianApproximation = 'lbfgs';
%         opts.HessFcn = @(x,kappa)build_hessian(zeros(Nx,Nx), Hessian(x,kappa.eqnonlin,0), rho, Sigma);
%     end

    options = optimoptions('lsqnonlin','SpecifyObjectiveGradient',true);

    objective    = @(x)build_objective_least_squares(x, r(x), drdx(x), [], lambda, A, rho, z, Sigma);
    xopt    = lsqnonlin(objective, x0, lbx, ubx, options);
    res.x = xopt;
%     res.lam_g = [multiplier.eqnonlin; multiplier.ineqnonlin];
%     res.lam_x = max(multiplier.lower, multiplier.upper);
    res.pars = [];
end


function [fun, jac] = build_objective_least_squares(x, r, drdx, H, lambda, A, rho, z, Sigma)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % the code assumes that Sigma is symmetric and positive definite!!!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fun = double( build_residual(x, r, lambda, A, rho, z, Sigma));
    if nargout > 1
        jac = double(build_jacobian(x, drdx, lambda, A, rho, z, Sigma));
    end
end


function fun = build_residual(x, r, lambda, A, rho, z, Sigma)
    fun = [r;sqrt(0.5*rho)*Sigma*(x - z)];
end

function fun = build_jacobian(x, drdx, lambda, A, rho, z, Sigma)
    fun = [drdx ; sqrt(0.5*rho)*Sigma];
end


function [fun, grad, Hessian] = build_objective(x, f, dfdx, H, lambda, A, rho, z, Sigma)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % the code assumes that Sigma is symmetric and positive definite!!!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fun = double( build_cost(x, f, lambda, A, rho, z, Sigma));
    if nargout > 1
        grad = double(build_grad(x, dfdx, lambda, A, rho, z, Sigma));
        if nargout > 2
            % only for fminunc
            Nx      = numel(x);
            Hessian = build_hessian(H,zeros(Nx,Nx), rho, Sigma);
        end
    end
end


function fun = build_cost(x, f, lambda, A, rho, z, Sigma)
    fun = f  + 0.5*rho*(x - z)'*Sigma*(x - z);
end

function grad = build_grad(x, dfdx, lambda, A, rho, z, Sigma)
    grad = dfdx + rho*Sigma'*(x - z);
end

function hm  = build_hessian(hessian_f, kappa_hessian_g, rho, Sigma, scale)
    if nargin > 4
        % worhp scale hessian_f
        hessian_f = hessian_f .* scale;
    end
    hm   = hessian_f + rho * Sigma + kappa_hessian_g;
end

function [ineq, eq, jac_ineq, jac_eq] = build_nonlcon(x, g, h, dgdx)
    ineq = h(x);
    eq = g(x);   
    if nargout > 2
        jac_ineq = [];
        jac_eq = dgdx(x)';
    end
end
