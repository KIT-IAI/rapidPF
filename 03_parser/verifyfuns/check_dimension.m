function bool = check_dimension(ang, mag, p, q)
    [data{1:4}] = deal(ang, mag, p, q);
    sizes = cellfun(@(x)size(x,1), data);
    if numel(unique(sizes)) == 1
        bool = true;
    else
        bool = false;
        error('inconsistent dimensions');
    end
end