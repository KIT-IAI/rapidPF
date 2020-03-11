% return the number of buses in casefile
% error when the buses do not lay in sequence in the casefile
function N = get_number_of_buses(mpc)
    N = size(mpc.bus, 1);
    % check 1:N numbering
    assert(sum(1:N) == sum(mpc.bus(:,1)), 'This code assumse 1:N numbering in buses. Please check.')
end