% check the number of branches in merged case-file is as expected
% M_transmission_system + M_distribution_system +1 = size(mpc.branch,1) 
function check_number_of_branches(M_transmission_system, M_distribution_system, M_conn, mpc)
    M_mpc = size(mpc.branch, 1);
    assert(M_transmission_system + M_distribution_system + M_conn == M_mpc, 'post_processing:check_number_of_branches', 'Total number of branches is not equal to the `sum of number of branches in both subsystems` + 1.')
end