% check the number of buses in merged case-file is as expected
% N_transmission_system + N_distribution_system = size(mpc.bus,1) for 
function check_number_of_buses(N_transmission_system, N_distribution_system, mpc)
    N_mpc = size(mpc.bus, 1);
    % check 1:N numbering
    assert(N_transmission_system + N_distribution_system == N_mpc, 'post_processing:check_number_of_buses', 'Total number of buses is not equal to the `sum of number of buses in both subsystems` .')
end