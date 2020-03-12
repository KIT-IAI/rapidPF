% determine the number of generators that are connected to bus `bus` in the
% casefile `mpc`
function n = get_number_of_connected_generators(mpc, bus)
    n = numel( find_generator_gen_entry(mpc, bus) );
end