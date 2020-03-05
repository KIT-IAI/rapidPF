function f = build_consensus_constraints(problem, x)
    N_regions = numel(problem.AA);
    f = 0;
    sizes = cellfun(@(x)numel(x), problem.zz0);
    n = 0;
    for i = 1:N_regions
        A = problem.AA{i};
        if iscell(x)
            y = x{i};
        else
            y = x(n + (1:sizes(i)));
        end
        
        f = f + A*y;
        
        n = n + sizes(i);
    end
end