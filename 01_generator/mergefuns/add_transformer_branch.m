% by convention we treat the transmission system side as the FROM side, and
% the distribution system side as the TO side
function mpc = add_transformer_branch(mpc, from_buses, to_buses, pars)
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