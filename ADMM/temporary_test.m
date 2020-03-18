global hi gi
N_state = size(problem.state{1},1);
Ai      = problem.AA{1};
lam0    = problem.lam0;
if isempty(problem.locFuns.hhi{1}(0))
    % fmincon fail when c(x) = []
    hi      = @(x)(zeros);
else
    hi      = problem.locFuns.hhi{1};
end
gi      = problem.locFuns.ggi{1};
hi      = @(x) zeros(size(x));
x0      = problem.zz0{1};
fi      = problem.locFuns.ffi{1};
rou     = 2;

%% create jacobian
options = optimoptions(@fminunc,'Display','iter','Algorithm','quasi-newton', 'MaxFunctionEvaluations', 10000);
    J = @(x)(fi(x) + lam0'*Ai*x + step_length(x,x0,Ai,rou));
%    norm(Ai*(x-x0))^2);
    y = fmincon(J, x0, [], [], [],[],[],[], @nonlinear_constraints,options);
    lam0 = lam0 + rou*Ai*(y-x0);

clear global



%% test ADMM
clc
params.max_iter = 200;
params.tol = 1;
params.rou = 3/4;
x = solve_distributed_problem_with_ADMM(problem, params);

%%
function [c, ceq] = nonlinear_constraints(x)
global hi gi
c = hi(x);
ceq =gi(x);
end

function n = step_length(x,y,A,rou)
    n = rou/2*norm(A*(x-y))^2;
end