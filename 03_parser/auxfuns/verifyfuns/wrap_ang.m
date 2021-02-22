function x = wrap_ang(x,mpc)
    % wrap ang variable in state x into [-pi,pi];
    N_region = numel(mpc.regions);
    
    % total bus number from region 1 to region (i-1)
    Nbus_core = 0;
    Nbus_copy = 0;
    
    for i = 1: N_region
        % bus number at current region i 
        Nbus_core_i = numel(mpc.regions{i});
        Nbus_copy_i = numel(mpc.copy_buses_global{i});
        % index of angle variable
        idx_ang_start = Nbus_core * 4 + Nbus_copy * 2 + 1;
        idx_ang_end   = idx_ang_start + Nbus_core_i + Nbus_copy_i-1;
        idx_ang       = idx_ang_start:idx_ang_end;
        % wrap angle variable
        x(idx_ang) = wrapToPi(x(idx_ang));
        % sum up total bus number
        Nbus_core = Nbus_core + Nbus_core_i;
        Nbus_copy = Nbus_copy + Nbus_copy_i;
    end

end