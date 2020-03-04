function [y, y_stacked] = extract_results_per_region_with_copies(mpc, names)
%     opt = mpoption;
%     opt.verbose = 0;
%     opt.out.all = 0;
%     res = runpf(mpc, opt);
    [x, x_stacked] = extract_results_per_region(mpc, names);
    [vang, vmag, pnet, qnet] = unstack_state(cell2mat(x));
    
    copy_local = mpc.(names.copy_buses.local);
    copy_global = mpc.(names.copy_buses.global);
    
    N_regions = numel(copy_local);
    [y, y_stacked] = deal(cell(N_regions, 1));
    
    for i = 1:N_regions
        vang_copy = vang(copy_global{i});
        vmag_copy = vmag(copy_global{i});
        N_copies = numel(vang_copy);
        state = x{i};
        [vang_, vmag_, pnet_, qnet_] = unstack_state(state);
        
        
        y{i} = [state; [vang_copy, vmag_copy,  NaN*ones(N_copies, 2)] ];
        y_stacked{i} = [ vang_; vang_copy; vmag_; vmag_copy; pnet_; qnet_ ];
    end
    
end