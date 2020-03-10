function names = generate_name_struct()
    names.regions.global = 'regions';
    names.regions.global_with_copies = 'connections_with_aux_nodes';
    names.regions.local = 'regions_local';
    names.regions.local_with_copies = 'regions_local_with_copies';
    names.copy_buses.local = 'copy_buses_local';
    names.copy_buses.global = 'copy_buses_global';
    names.connections.local = 'connections_global';
    names.connections.global = 'connections';
    names.split = 'split_case_files';
end