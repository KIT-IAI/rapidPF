function pars = generate_merge_info(trans_bus, dist_bus, trafo_params, fields_to_merge)
% generate_merge_info
%
%   `copy the declaration of the function in here (leave the ticks unchanged)`
%
%   _describe what the function does in the following line_
%
%   # Markdown formatting is supported
%   Equations are possible to, e.g $a^2 + b^2 = c^2$.
%   So are lists:
%   - item 1
%   - item 2
%   ```matlab
%   function y = square(x)
%       x^2
%   end
%   ```
%   See also: [run_case_file_splitter](run_case_file_splitter.md)
    pars.transformer.transmission_bus = trans_bus;
    pars.transformer.distribution_bus = dist_bus;
    pars.transformer.params = trafo_params;
    pars.fields_to_merge = fields_to_merge;
end