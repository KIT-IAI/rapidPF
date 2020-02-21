% replace slack by PV, replace generators by PQ
% attention: mpc should be distribution casefile
function mpc = replace_slack_and_generators(mpc, trafo_bus)
% mpc         -- distribution casefile
% trasfo_bus -- the bus in TS conneted to the trafo
    slack_bus = find_slack_bus(mpc);   % ref
    if trafo_bus == slack_bus        
        % slack bus and transformer bus coincide
        % hence, replace this generation bus by PQ bus
        warning('The slack bus and the transformer bus coincide.');
        mpc = replace_slack(mpc, 'pq'); % replace generator  
    else
        % slack bus and transformer bus DO NOT coincide
        warning('The slack bus and the transformer bus DO NOT coincide. Check results carefully.');
        % then, replace transformer bus by PQ bus, I.e. pure load bus
        mpc = replace_generator(mpc, trafo_bus, 'pq');
        % and, replace slack bus by PV bus, gen still working
        mpc = replace_slack(mpc, 'pv');
    end
end