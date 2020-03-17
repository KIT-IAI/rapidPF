function mpc = replace_slack_and_generators(mpc, trafo_buses)
% replace_slack_and_generators
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