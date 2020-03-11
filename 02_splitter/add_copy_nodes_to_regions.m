function mpc = add_copy_nodes_to_regions(mpc, names)
    regions = mpc.(names.regions.global);
    copy_nodes = mpc.(names.copy_buses.global);
    
    assert(numel(regions) == numel(copy_nodes), 'inconsistent dimensions.')
    Nregions = numel(regions);
    
    regions_with_copy_nodes = cell(Nregions, 1);
    for i = 1:Nregions
        regions_with_copy_nodes{i} = [regions{i} sort(copy_nodes{i})'];
    end
    mpc.(names.regions.global_with_copies) = regions_with_copy_nodes;
end