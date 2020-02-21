function mpc = add_region_information(mpc, N_currently, N_to_add)
% INPUT 
% mpc         -- casefile
% N_currently -- the number of buses for current TS casefile
% N_to_add    -- the number of buses for added DS casefile
    global NAME_FOR_REGION_FIELD
    N_regions = length(mpc.(NAME_FOR_REGION_FIELD));
    mpc.(NAME_FOR_REGION_FIELD){N_regions + 1} = (1:N_to_add) + N_currently;
end