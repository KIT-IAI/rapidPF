function bool = has_correct_size(f, N)
    if numel(f) == N
        bool = true;
    else
        bool = false;
        error('incorrect function dimensions.');
    end
end