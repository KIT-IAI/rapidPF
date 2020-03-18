costs              = problem.locFuns.ffi;
equalities         = problem.locFuns.ggi;
inequalities       = problem.locFuns.hhi;
AA                 = problem.AA;
state              = problem.state;
Y                  = problem.zz0;
x0 = cell2mat(Y);
lam0 = problem.lam0;
N_regions = size(AA,1);

    Lambda             = {};
    for i = 1:N_regions
        Lambda{i} = lam0;
    end



%%
J = 0;
for i = 1:N_regions
    J = J + penalty_term(state{i},Y{i},AA{i},rou) - Lambda{i}'*AA{i}*state{i};
end
JJ = matlabFunction(J);



%%
    rou = 3/4;  
    J   = 0;
    N_states = get_number_of_state(state);
    n   = 1;
    b                  = problem.b;
    Aeq = cell2mat(AA');  % equality constraints

    x = sym('x_',[sum(N_states),1]);
    
    for i=1:N_regions
        m = n + N_states(i) - 1;
        J = J + penalty_term(x(n:m),Y{i},AA{i},rou) ...
              - Lambda{i}'*AA{i}*x(n:m);
        n = n + N_states(i);
    end
    J = matlabFunction(J,'Vars',{x});
    x   = fmincon(@(x)J(x), x0,[],[],Aeq,b);



function n = penalty_term(x,y,A,rou)
    n = rou/2*norm(A*(x-y))^2;
end

%%
function N_states = get_number_of_state(X)
% get the numbers of states in each region
    N_regions = size(X,1);
    N_states = [];
    for i = 1:N_regions
        N_states(i) = size(X{i},1);
    end
end
