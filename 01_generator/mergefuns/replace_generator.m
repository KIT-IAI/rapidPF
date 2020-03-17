function mpc = replace_generator(mpc, bus, replace_by, msg)
% replace_generator
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

    % using index instead of number
    [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
        VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus; 
    
    [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
    % check bus type is either PG or PV
    check_bus_type(replace_by);   % original bus type
    
    if nargin == 3
        msg = 'generator';
    end

    % get indices for the selected generators in GEN_DATA
    gen_entries = find_generator_gen_entry(mpc, bus); 
     
    % sanity check: are all voltage magnitudes the same?
    if check_voltage_magnitudes(mpc, gen_entries)
        mpc.bus(bus, VM) = mpc.gen(gen_entries(1), VG);
    end
    
    % replace the bus type according 'replace_by'
    if lower(replace_by) == 'pq'        % converts all uppercase characters
        mpc.bus(bus, BUS_TYPE) = PQ;
        for i = 1:numel(gen_entries)
            check_power_generation_at_generators(mpc, gen_entries(i));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % as default, the generated power at the generator WILL NOT be
            % considered.
            % alternatively, the following may be used
%             mpc.bus(bus, PD) = mpc.bus(bus, PD) - mpc.gen(gen_entries(i), PG);
%             mpc.bus(bus, QD) = mpc.bus(bus, QD) - mpc.gen(gen_entries(i), QG);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
%             mpc.gen(gen_entries(i), :) = [];
%             % remove generator cost entries from case file
%             if isfield(mpc, 'gencost')
%                 mpc.('gencost')(gen_entries(i), :) = [];
%             end
        end
        mpc.gen(gen_entries, :) = [];
        if isfield(mpc, 'gencost')
            mpc.('gencost')(gen_entries, :) = [];
        end
    elseif lower(replace_by) == 'pv'
        % when bus type 'ref' -> 'PV', no need to remove generator information from Gen_data
        mpc.bus(bus, BUS_TYPE) = PV;
    else
        error('Unknown bus type `%s`', replace_by);
    end
end

function bool = check_voltage_magnitudes(mpc, gen_entries)    
    [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;

    if range(mpc.gen(gen_entries, VG)) == 0 
        bool = true;
    else
        bool = false;
        error('Inconsistent voltage magnitude settings.');
    end
end

% error when the bus type is neither PQ nor PV
function check_bus_type(bus_type)
    if length(bus_type) ~= length('pq') || length(bus_type) ~= length('pv')
        error('Unknown bus type `%s`', bus_type);
    end
end