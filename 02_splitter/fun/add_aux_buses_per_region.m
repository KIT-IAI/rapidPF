function mpc = add_aux_buses_per_region(mpc, names)
    NAME_FOR_AUX_BUSES_FIELD = names.copy_buses.global;
    NAME_FOR_AUX_FIELD = names.regions.global_with_copies;
    NAME_FOR_REGION_FIELD = names.regions.global;
    %%
    buses_in_regions = mpc.(NAME_FOR_REGION_FIELD);
    buses_in_regions_with_aux_nodes = mpc.(NAME_FOR_AUX_FIELD);
    N_regions = numel(buses_in_regions_with_aux_nodes);
    [aux_nodes_per_region{1:N_regions}] = deal([]);
    for i = 1:N_regions
        aux_nodes_per_region{i} = setdiff(buses_in_regions_with_aux_nodes{i}, buses_in_regions{i});
    end
    mpc.(NAME_FOR_AUX_BUSES_FIELD) = aux_nodes_per_region;
end