function mpc = split_and_makeYbus(mpc, names)
    NAME_FOR_REGION_FIELD = names.regions.global;
    NAME_FOR_SPLIT_CASE_FILE = names.split;
    
    N_regions = numel(mpc.(NAME_FOR_REGION_FIELD));
    [Y, mpc_cell] = deal(cell(N_regions, 1));
    for N = 1:N_regions
        mpc_cell{N} = split_case_file(mpc, N, names);
        Y{N} = makeYbus(ext2int(mpc_cell{N}));
    end
    mpc.Y = Y;
    mpc.(NAME_FOR_SPLIT_CASE_FILE) = mpc_cell;
end

