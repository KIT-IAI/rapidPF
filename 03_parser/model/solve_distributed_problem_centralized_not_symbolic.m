function [xsol, xsol_stacked] = solve_distributed_problem_centralized_not_symbolic(mpc, problem, names)
    Nregions = numel(problem.AA);

    sizes = cellfun(@(x)numel(x), problem.xx0);
    x0 = cat(1, problem.xx0{:});
    
    lb = cat(1, problem.lbx{:});
    ub = cat(1, problem.ubx{:});
    xsol = fmincon(@(x)0*sum(x), x0, [], [], [], [], lb, ub, @(x)build_con(x, problem, sizes));
    
    %% deal solution back
    [xsol, xsol_stacked] = deal_solution(xsol, mpc, names);
    
    
end

function [ineq, eq] = build_con(x, problem, buses)
    x_split = split_vector(x, buses);
    n = numel(buses);
    eq_temp = cell(n, 1);
    consensus = zeros(size(problem.AA{1}, 1), 1);
    for i = 1:n
        g = problem.ggi{i};
        eq_temp{i} = g(x_split{i});
        consensus = consensus + problem.AA{i} * x_split{i};
    end
    
    eq = [ cell2mat(eq_temp); consensus ];
    ineq = [];
end

function y = split_vector(x, buses)
    n = numel(buses);
    ncum = [0; cumsum(buses)];
    y = cell(n, 1);
    for i = 1:n
        ncum(i) + (1:buses(i));
        y{i} = x(ncum(i) + (1:buses(i)));
    end
    
end


