function [N_regions, N_buses_in_regions, N_copy_buses_in_regions, N_core_buses_in_regions] = get_relevant_information(mpc, names)
    N_regions = numel(mpc.(names.regions.global));
    N_buses_in_regions = cellfun(@(x)numel(x), mpc.(names.regions.global_with_copies));
    N_copy_buses_in_regions = cellfun(@(x)numel(x), mpc.(names.copy_buses.global));
    N_core_buses_in_regions = cellfun(@(x)numel(x), mpc.(names.regions.global));
end