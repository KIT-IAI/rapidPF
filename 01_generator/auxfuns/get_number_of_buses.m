function N = get_number_of_buses(mpc)
% get_number_of_buses
%
%   `N = get_number_of_buses(mpc)`
%
%   _Get the number of buses in a case file_
%
%   ## See also:
%   - [get_number_of_branches](get_number_of_branches.md)
%   - [get_number_of_connected_generators](get_number_of_connected_generators.md)
%   - [get_number_of_generators](get_number_of_generators.md)
    N = size(mpc.bus, 1);
    % check 1:N numbering
    assert(sum(1:N) == sum(mpc.bus(:,1)), 'This code assumse 1:N numbering in buses. Please check.')
end