function names = generate_name_struct()
% generate_name_struct
%
%   `names = generate_name_struct()`
%
%   _Generate a struct that contains naming conventions._
%
%   ## Inputs
%
%   Input | Type | Description 
%   :--- | :--- | :--- 
%   n/a |
%
%   </br>
%   ## Outputs
%
%   Output | Type | Description
%   :--- | :--- | :---
%   `names` | `struct` | struct containing naming conventions
%
%   </br>
%   ## See also
%   </br>
    names.regions.global = 'regions';
    names.regions.global_with_copies = 'connections_with_aux_nodes';
    names.regions.local = 'regions_local';
    names.regions.local_with_copies = 'regions_local_with_copies';
    names.copy_buses.local = 'copy_buses_local';
    names.copy_buses.global = 'copy_buses_global';
    names.connections.local = 'connections_global';
    names.connections.global = 'connections';
    names.split = 'split_case_files';
    names.consensus = 'consensus';
end