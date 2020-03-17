function mpc = add_transformer_branch(mpc, from_buses, to_buses, pars)
% add_transformer_branch
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
    assert(numel(from_buses) == numel(to_buses), 'inconsistent dimensions');
    for i = 1:numel(from_buses)
        from_bus = from_buses(i);
        to_bus = to_buses(i);
        par = pars{i};
        assert(from_bus < to_bus, 'Per convention, the transformer connects TRANSMISSION to DISTRIBUTION, where TRANSMISSION bus numbers must be lower than DISTRIBUTION bus numbers.');
        branch_entry = generate_branch_entry(from_bus, to_bus, par.r, par.x, par.b, par.ratio, par.angle);
        mpc.branch = [mpc.branch; branch_entry];
    end
end