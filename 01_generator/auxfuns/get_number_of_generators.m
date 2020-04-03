function N = get_number_of_generators(mpc)
% get_number_of_generators
%
%   `N = get_number_of_generators(mpc)`
%
%   _Get number of generators in case file_
%
%   ## See also:
%   - [get_number_of_branches](get_number_of_branches.md)
%   - [get_number_of_buses](get_number_of_buses.md)
%   - [get_number_of_connected_generators](get_number_of_connected_generators.md)
N = size(mpc.gen, 1); % numbers of generator in totoal
end