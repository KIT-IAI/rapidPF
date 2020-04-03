% check the number of generators in merged case-file is as expected
% error when the Ngen_trans + Ngen_dist - Ngen_trafo_dist_bus ~= Ngen_mpc
function check_number_of_generators(Ngen_trans, Ngen_dist, Ngen_trafo_dist_bus, Ngen_mpc)
    assert(Ngen_trans + Ngen_dist - sum(Ngen_trafo_dist_bus) == Ngen_mpc, 'post_processing:check_number_of_generators', 'There is something wrong the number of generators (expected %i, got %i).', Ngen_trans + Ngen_dist - Ngen_trafo_dist_bus, Ngen_mpc)
end