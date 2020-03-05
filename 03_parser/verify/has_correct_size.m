function has_correct_size(fun, n)
    assert(numel(fun) == n, 'incorrect function dimensions.');
end