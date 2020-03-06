function [xsol, xsol_stacked, mpc_sol] = solve_distributed_problem_centralized(mpc, problem, names)
    sizes = cellfun(@(x)numel(x), problem.zz0);
    x0 = vertcat(problem.zz0{:});
    totTimer   = tic;
    [xsol,~,~,OUTPUT] = fsolve(@(x)build_con(x, problem, sizes), x0);
    elapsed_time  =  toc(totTimer);
    % deal solution back
    [xsol, xsol_stacked] = deal_solution(xsol, mpc, names);
    
    % numerical solution back to matpower casefile
    iter          =  OUTPUT.iterations; % number of iteration
    alg           =  OUTPUT.algorithm;
    mpc_sol       =  back_to_mpc(mpc, xsol, elapsed_time, iter, alg);end

function eq = build_con(x, problem, buses)
    x_split = split_vector(x, buses);
    n = numel(buses);
    eq_temp = cell(n, 1);
    consensus = zeros(size(problem.AA{1}, 1), 1);
    for i = 1:n
        g = problem.locFuns.ggi{i};
        eq_temp{i} = g(x_split{i});
        consensus = consensus + problem.AA{i} * x_split{i};
    end
    eq = [ cell2mat(eq_temp); consensus ];
end

function y = split_vector(x, buses)
    n = numel(buses);
    ncum = [0; cumsum(buses)];
    y = cell(n, 1);
    for i = 1:n
        y{i} = x(ncum(i) + (1:buses(i)));
    end
end


