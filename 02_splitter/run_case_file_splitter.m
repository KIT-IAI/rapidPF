function mpc = run_case_file_splitter(mpc_merge, conn, names)
    mpc = add_copy_nodes(mpc_merge, conn, names);
    mpc = add_copy_nodes_to_regions(mpc, names);
    mpc = split_and_makeYbus(mpc, names);
    mpc = add_consensus_information(mpc, conn, names);
    
    savecase('mpc_merge_split.m', mpc);
end