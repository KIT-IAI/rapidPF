function mpc = run_case_file_generator(mpc_master, mpc_slaves, connection_table, fields_to_merge, names)
% run_case_file_generator
%
%   `mpc = run_case_file_generator(mpc_master, mpc_slaves, connection_table, fields_to_merge, names)`
%
%   _Generate a merged case file `mpc` from `mpc_master` and `mpc_slaves` according to the `connection_table`_
%
%   The auxiliary inputs `fields_to_merge` and `names` are basic requirements with obvious meanings.
    mpc = create_skeleton_mpc({mpc_master}, fields_to_merge, names);
    tab = connection_table;
    Ncount = get_number_of_buses(mpc_master);
    for i = 1:numel(mpc_slaves)
        fprintf('\nMerging slave system #%i\n', i);
        merge_info = generate_merge_info_from_table(i+1, tab, fields_to_merge);
        mpc = merge_systems(mpc, mpc_slaves{i}, merge_info, names);

        tab = update_connections(tab, i+1, Ncount);
        Ncount = Ncount + get_number_of_buses(mpc_slaves{i});
    end

    savecase('mpc_merge.m', mpc)
end

function tab = update_connections(tab, i, Nshift)
    assert(i > 1, 'cannot update the master system.');
    
    to_be_deleted = [];
    
    for k = 1:height(tab)
        row = tab(k, :);
        from_sys = row.from_sys;
        to_sys = row.to_sys;
        assert(from_sys < to_sys, 'inconsistent ordering');
        
        if from_sys == 1 && to_sys == i
            to_be_deleted = [to_be_deleted; k];
        elseif from_sys == i
            tab.from_bus(k) = tab.from_bus(k) + Nshift;
            tab.from_sys(k) = 1;
        end
    end
    
    tab(to_be_deleted, :) = [];
end

function info = generate_merge_info_from_table(i, tab, fields_to_merge)
    rows = find((tab.from_sys == i & tab.to_sys == 1) | (tab.to_sys == i & tab.from_sys == 1));
    info = generate_merge_info(tab.from_bus(rows), tab.to_bus(rows), tab.trafo_pars(rows), fields_to_merge); 
end

function pars = generate_merge_info(trans_bus, dist_bus, trafo_params, fields_to_merge)
    pars.transformer.transmission_bus = trans_bus;
    pars.transformer.distribution_bus = dist_bus;
    pars.transformer.params = trafo_params;
    pars.fields_to_merge = fields_to_merge;
end

