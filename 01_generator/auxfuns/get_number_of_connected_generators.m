function N = get_number_of_connected_generators(mpc, bus)
% get_number_of_connected_generators
%
%   `N = get_number_of_connected_generators(mpc, bus)`
%
%   _Get number of generators in case file `mpc` connected to `bus`_
%
%   ## See also:
%   - [get_number_of_branches](get_number_of_branches.md)
%   - [get_number_of_buses](get_number_of_buses.md)
%   - [get_number_of_generators](get_number_of_generators.md)
    N = numel( find_generator_gen_entry(mpc, bus) );
end