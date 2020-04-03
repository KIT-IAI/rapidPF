% check whether the connected bus is a PV / ref bus
% error when the bus is a PQ bus, I.e. non-generator bus
function check_connection(mpc, bus, sys)
% INPUT:
% mpc: current casefile
% bus: bus number for connection in mpc
% sys: system name
    assert(is_generator(mpc, bus), 'post_processing:check_connection', '[%s system] Transformer would be connected to a non-generation bus.', sys)
end