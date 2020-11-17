clc
clear
close all


%% load testfile

mpc = loadcase('case5');  
[mpc_opf, mpopt] = opf_args(mpc); 
[Ybus, Yf, Yt] = makeYbus(mpc);
mpc_opf = ext2int(mpc_opf, mpopt);
om = opf_setup(mpc_opf, mpopt);


%% get opf functions
% found  in mipsopf_solver.m at lines 125 ff.

il = find(mpc.branch(:, 6) ~= 0 & mpc.branch(:, 6) < 1e10);
%nl2 = length(il);           %% number of constrained lines


f_fcn =    @(x)opf_costfcn(x, om);
gh_fcn =   @(x)opf_consfcn(x, om, Ybus, Yf(il,:), Yt(il,:), mpopt, il);
hess_fcn = @(x, lambda, cost_mult)opf_hessfcn(x, lambda, cost_mult, om, Ybus, Yf(il,:), Yt(il,:), mpopt, il);


f   = @(x)get_cost(x, f_fcn);
df  = @(x)get_cost_gradient(x, f_fcn);
d2f = @(x)get_cost_hess(x, f_fcn);
g   = @(x)get_eq_cons(x, gh_fcn);
dg  = @(x)get_eq_cons_gradient(x, gh_fcn);
h   = @(x)get_ineq_cons(x, gh_fcn);
dh  = @(x)get_ineq_cons_gradient(x, gh_fcn);
Lxx = @(x, lambda, cost_mult)opf_hessfcn(x, lambda, cost_mult, om, Ybus, Yf(il,:), Yt(il,:), mpopt, il);

result=runopf('case5');
x = result.x;
% compare to function output
cost_at_x = f(x);
grad_cost_at_x = df(x);

%% set_up_problem

problem.locFuns.ffi = @(x)f(x);
problem.locFuns.ggi = @(x)g(x);
problem.locFuns.hhi = @(x)h(x);

dims.eq = om.nle.N;
dims.ineq = om.nli.N;

problem.sens.gg   = @(x) df(x);
problem.sens.JJac = @(x)[dg(x);dh(x)];
problem.sens.HH   = @(x, kappa, rho)Lxx(x, kappa, 1.0);

[x0, xmin, xmax] = om.params_var;
problem.zz0{1} = x0;
problem.llbx{1} = xmin;
problem.uubx{1} = xmax;
A{1}=zeros(length(x0), length(x0));
problem.AA = A;

problem.solver = 'fmincon';

%% sanity checks

%% run ALADIN
% Autsch, geht noch nicht...
% Grad liegt das an den Sanity checks von ALADIN, weil wir ja in voller
% Absicht ein Problem rein tun, was nicht gekoppelt ist....
%
% Was wir dagegen tun könnten, wäre, unser Problem zu verdoppeln, also zwei
% mal das gleiche Problem in ALADIN zu stopfen um danach als
% Kopplungsbedingung zu erwarten, dass in beiden Problemen das gleiche
% heraus kommt...

% run_ALADINnew(problem);

%% helper functions
function f = get_cost(x, f_fcn)
    [f,~] = f_fcn(x);
end

function df = get_cost_gradient(x, f_fcn)
    [~, df] = f_fcn(x);
end

function d2f = get_cost_hess(x, f_fcn)
    [~,~,d2f] = f_fcn(x);
end

function g = get_eq_cons(x, gh_fcn)
    [g,~,~,~] = gh_fcn(x);
end

function h = get_ineq_cons(x, gh_fcn)
    [~,h,~,~] = gh_fcn(x);
end

function dg = get_eq_cons_gradient(x, gh_fcn)
    [~,~,dg,~] = gh_fcn(x);
end

function dh = get_ineq_cons_gradient(x, gh_fcn)
    [~,~,~,dh] = gh_fcn(x);
end