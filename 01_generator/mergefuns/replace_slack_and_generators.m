% replace slack by PV, replace generators by PQ
% attention: mpc should be distribution casefile
function mpc = replace_slack_and_generators(mpc, trafo_buses)
% mpc         -- distribution casefile
% trasfo_bus -- the bus in TS conneted to the trafo
    slack_bus = find_slack_bus(mpc);   % ref
    % does any trafo_bus correspond to the slack bus?
    trafo_slack_bus = trafo_buses(trafo_buses == slack_bus);
    trafo_buses = [ trafo_slack_bus;
                    setdiff(trafo_buses, trafo_slack_bus) ];
    
    replaced_slack = false;
    for i = 1:numel(trafo_buses)
        trafo_bus = trafo_buses(i);
        if trafo_bus == slack_bus        
            % slack bus and transformer bus coincide
            % hence, replace this generation bus by PQ bus
            warning('The slack bus and the transformer bus coincide.');
            if ~replaced_slack
                mpc = replace_slack(mpc, 'pq'); % replace generator  
                replaced_slack = true;
            end
        else
            % slack bus and transformer bus DO NOT coincide
            warning('The slack bus and the transformer bus DO NOT coincide. Check results carefully.');
            % then, replace transformer bus by PQ bus, I.e. pure load bus
            mpc = replace_generator(mpc, trafo_bus, 'pq');
            % and, replace slack bus by PV bus, gen still working
            if ~replaced_slack
                mpc = replace_slack(mpc, 'pv');
                replaced_slack = true;
            end
        end
    end
end