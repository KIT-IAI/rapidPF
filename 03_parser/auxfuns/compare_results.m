function tab = compare_results(x, y)
    assert(numel(x) == numel(y), 'inconsistent number of elements');
    dx = cell2mat(arrayfun(@(i)norm(x{i} - y{i}, Inf), 1:numel(x), 'UniformOutput', false))';
    regions = [1:numel(x)]';
    tab = table(regions, dx);
    tab.Properties.Description = 'Inf-norm of power flow solutions';
    tab.Properties.VariableNames = {'Regions', 'Inf-Norm of residual'};
end