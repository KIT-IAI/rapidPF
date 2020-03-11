% change the bus type for the slack bus
function mpc = replace_slack(mpc, replace_by)
% INPUT
% mpc        -- casefile
% replace by -- the new bus type for this bus
    slack_bus = find_slack_bus(mpc);
    mpc = replace_generator(mpc, slack_bus, replace_by, 'slack');
end