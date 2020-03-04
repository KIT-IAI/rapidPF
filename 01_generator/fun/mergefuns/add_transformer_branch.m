% by convention we treat the transmission system side as the FROM side, and
% the distribution system side as the TO side
function mpc = add_transformer_branch(mpc, from_bus, to_bus, pars)
    assert(from_bus < to_bus, 'Per convention, the transformer connects TRANSMISSION to DISTRIBUTION, where TRANSMISSION bus numbers must be lower than DISTRIBUTION bus numbers.');
    
    branch_entry = generate_branch_entry(from_bus, to_bus, pars.r, pars.x, pars.b, pars.ratio, pars.angle);
    mpc.branch = [mpc.branch; branch_entry];
end