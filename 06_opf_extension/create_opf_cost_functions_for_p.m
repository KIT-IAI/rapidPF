function fun = create_opf_cost_functions_for_p(Pnet, gencosts, mpc, local_bus_to_remove)
% create_power_flow_equation_for_p
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
fun = 0;

% copied from create_bus_specifications
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
        VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
        MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
        QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;

if nargin == 5
    local_bus_to_remove = [];
end
mpopt = mpoption;
    mpc = ext2int(mpc, mpopt);
    % if isfield(mpc, 'gencost')
    % [baseMVA, bus, gen, gencost] = deal(mpc.baseMVA, mpc.bus, mpc.gen, mpc.gencost);
    % else
    [baseMVA, bus, gen, gencost] = deal(mpc.baseMVA, mpc.bus, mpc.gen, mpc.gencost);
        
    % end
    [ref, pv, pq] = bustypes_ref(bus, gen);
    
    if ~isempty(local_bus_to_remove)
        [ref, pv, pq] = remove_bus(local_bus_to_remove, ref, pv, pq);
       % remove gen cost entries.
       gencost_without_copies = remove_gen_cost_entries(gen, gencost, bus, local_bus_to_remove);
       % end
       % bus = bus_without_copies;
       % gen = gen_without_copies;
        gencosts = gencost_without_copies;
        
            
    end

N_generators = size(gencosts, 1);
for i = 1:N_generators
    if gencosts(i, 1) == 1
        warning('Cost model 1 is not supported. Handle solution with care!')
        fun = fun + calculate_fi_wrt_model_1(i, Pnet, gencosts, fun);
    elseif gencosts(i, 1) == 2
        fun = fun + calculate_fi_wrt_model_2(i, Pnet, gencosts, fun);
    else
        assert('Model of generator costs is not supported')
    end
end
end

function fun = calculate_fi_wrt_model_1(i, Pnet, gencosts, funvalue)
% return cost under linear cost model
n_cost_coefficients = gencosts(i, 4);
if ~(gencosts(i, 4 + 1) > Pnet(i) || Pnet(i) > gencosts(i, 4 + 2 * n_cost_coefficients - 1))
    for j = 1 : n_cost_coefficients/2
        if gencosts(i, 4 + j) <= Pnet(i) && Pnet(i) < gencosts(i, 4 + j + 2)
            fun = funvalue + gencosts(i, 4 + j + 1) + (Pnet(i) - gencosts(i, 4 + j)) ...
                * (gencosts(i, 4 + j + 3) - gencosts(i, 4 + j + 1))/ ...
                (gencosts(i, 4 + j + 2) - gencosts(i, 4 + j));
        end
    end
elseif Pnet(i) <= gencosts(i, 4 + 1)
    fun = funvalue + gencosts(i, 4 + 1 +1);
elseif Pnet(i) > gencosts(i, 4 + 2 * n_cost_coefficients - 1)
    fun = funvalue + gencosts(i, 4 + 2 * n_cost_coefficients);
end
end

function fun = calculate_fi_wrt_model_2(i, Pnet, gencosts, funvalue)
n_cost_coefficients = gencosts(i, 4);
for j = 1 : n_cost_coefficients - 1
    fun = funvalue + gencosts(i, 4 + j)*Pnet(i)^(n_cost_coefficients - j);
end
    fun = fun + gencosts(i, 4 + n_cost_coefficients);
end

function f = reshape_to_bus_numbering(f, bus_types)
    [~, sort_to_bus_numbering] = sort(bus_types);
    f = f(sort_to_bus_numbering, :);
    f = reshape(f', 2*numel(bus_types), 1);
end

function [ref, pv, pq] = remove_bus(bus, ref, pv, pq)
    ref = setdiff(ref, bus);
    pv = setdiff(pv, bus);
    pq = setdiff(pq, bus);
end

function bus = remove_bus_entries(bus, buses)
    bus(buses, :) = [];
end

function gen = remove_gen_entries(gen, bus, buses)
    [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
            MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
            QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
    
    types = get_bus_types(bus, buses);
    if has_slack_entry(types)
        error('asked to remove the slack. bad idea.');
    elseif has_pv_entry(types)
        % there is at least one PV bus, hence remove the corresponding gen
        % entry
        inds = ismember(gen(:, GEN_BUS), buses);
        gen(inds, :) = [];
    end
end

 function gencost = remove_gen_cost_entries(gen, gencost, bus, buses)
     [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
            MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
            QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
     
    types = get_bus_types(bus, buses);
    if has_pv_entry(types)
        % there is at least one PV bus, hence remove the corresponding
        % gencost entry
        inds = ismember(gen(:, GEN_BUS), buses);
        gencost(inds, :) = [];
    end
        
 end

function bool = has_pv_entry(types)
    [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
        VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
    bool = has_element(types, PV);
end

function bool = has_slack_entry(types)
    [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
        VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
    bool = has_element(types, REF);
end

function bool = has_element(vec, x)
    set = intersect(vec, x);
    if isempty(set)
        bool = false;
    else
        bool = true;
    end
end

function types = get_bus_types(bus, buses)
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
        VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
    types = bus(buses, BUS_TYPE);
end
