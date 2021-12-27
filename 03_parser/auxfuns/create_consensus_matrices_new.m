function [A, b] = create_consensus_matrices_new(tab, number_of_buses_in_region, number_of_copy_buses_in_region, entries, state0_all)
% create_consensus_matrices
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
    assert(istable(tab), 'expecting tab to be a table.');
    assert(mod(height(tab), 2) == 0, 'inconsistent number of consensus restrictions.')
    assert(numel(number_of_buses_in_region) == numel(number_of_copy_buses_in_region), 'inconsistent dimensions');
    
    % consensus for voltage angles
    [Aang, b_ang] = build_consensus_matrix(tab, number_of_buses_in_region, number_of_copy_buses_in_region, 'ang', entries, state0_all);
    % consensus for voltage magnitudes
    [Amag, b_mag] = build_consensus_matrix(tab, number_of_buses_in_region, number_of_copy_buses_in_region, 'mag', entries, state0_all);
    % stack together and check for correct dimensions
    A = stack_and_check(Aang, Amag, height(tab), number_of_buses_in_region, number_of_copy_buses_in_region);
    
    % stack b
    b = b_ang;
    for i = 1:numel(b)
        b{i} = [b_ang{i}; b_mag{i}];
    end
end

function A = stack_and_check(Aang, Amag, Nconsensus, number_of_buses_in_region, number_of_copy_buses_in_region)
    assert(numel(Aang) == numel(Amag), 'inconsistent dimensions.');
    A = Aang;
    Nrows = 2*Nconsensus;
    for i = 1:numel(Amag)
        A{i} = [ Aang{i}; Amag{i} ];
        
        Ncopy = number_of_copy_buses_in_region(i);
        Ncore = number_of_buses_in_region(i) - Ncopy;
        Ncols = 4*Ncore + 2*Ncopy;
        
        % assert(prod(size(A{i}) == [Nrows, Ncols]) == 1, 'inconsistent dimensions for consensus matrix in region %i', i);
    end
end

function [A, b] = build_consensus_matrix(tab, number_of_buses_in_region, number_of_copy_buses_in_region, Nshift, entries, state0_all)
    [A, b] = build_consensus_matrix_core(tab, number_of_buses_in_region, Nshift, entries, state0_all);
    A = delete_copy_bus_p_q_entries(A, number_of_copy_buses_in_region, entries);
end

function [A, b] = build_consensus_matrix_core(tab, number_of_buses_in_region, kind, entries, state0_all)
    kind = lower(kind);
    Nconsensus = height(tab);
%     assert(kind == 'ang' | kind == 'mag', 'kind %s is not supported (only `ang` or `mag`).');
    Nregions = numel(number_of_buses_in_region);
    A = cell(Nregions, 1);
    b = cell(Nregions, 1);
    for i = 1:Nregions
        A{i} = sparse(Nconsensus, 4*number_of_buses_in_region(i));
        b{i} = sparse(Nconsensus, 1);
    end
    
    for i = 1:Nconsensus
        orig_sys = tab.orig_sys(i);
        copy_sys = tab.copy_sys(i);
        orig_bus = tab.orig_bus_local(i);
        copy_bus = tab.copy_bus_local(i);
        
        is_pv = 0;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% the following code (implictly) assumes that the state in each
        %%% region is stacked according to x = [vang, vmag, pnet, qnet],
        %%% hence some shifting might be necessary, depending on whether we
        %%% build consensus for the voltage angle or voltage magnitude.
        if kind == 'ang'
            Norig = 0;
            Ncopy = 0;
        elseif kind == 'mag'
            Norig = number_of_buses_in_region(orig_sys);
            Ncopy = number_of_buses_in_region(copy_sys);
            
            % if orig_bus in pv, put -vmag in b
            if any(orig_bus == entries{orig_sys}.constant.pv)
                b{orig_sys}(i, 1) = -state0_all{orig_sys}(orig_bus + Norig);
                is_pv = 1;
            end
        else
            error('kind %s is not supported', kind);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        orig_bus_entry = orig_bus + Norig;
        copy_bus_entry = copy_bus + Ncopy;
        
        A{orig_sys}(i, orig_bus_entry) = 1;
        A{copy_sys}(i, copy_bus_entry) = -1;
        
%         if is_pv ==1
%             A{copy_sys}(i, copy_bus_entry) = 0;
%         end
    end
end

function A = delete_copy_bus_p_q_entries(A, copy_buses, entry)
    for i = 1:numel(copy_buses)
        entries = A{i};
        [~, cols] = size(A{i});
        entries(:,cols:-1:cols-2*copy_buses(i)+1) = [];
        A{i} = entries;
        
        % delete the part for constants
        A{i}(:, entry{i}.constant.stack) = [];
    end
end