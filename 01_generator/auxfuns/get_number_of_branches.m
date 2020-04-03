function N = get_number_of_branches(mpc)
% get_number_of_branches
%
%   `N = get_number_of_branches(mpc)`
%
%   _Get number of branches in case file `mpc`_
%
%   ## See also:
%   - [get_number_of_buses](get_number_of_buses.md)
%   - [get_number_of_connected_generators](get_number_of_connected_generators.md)
%   - [get_number_of_generators](get_number_of_generators.md)
    N = size(mpc.branch, 1);
end