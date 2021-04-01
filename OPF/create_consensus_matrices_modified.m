function AA = create_consensus_matrices_modified(tab, Nx_in_regions, Nbus_in_regions)
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
%     assert(numel(Nx_in_regions) == numel(Ncopy_in_regions), 'inconsistent dimensions');
    % consensus for voltage angles
    Aang = build_consensus_matrix(tab, Nx_in_regions, Nbus_in_regions, 'ang');
    % consensus for voltage magnitudes
    Amag = build_consensus_matrix(tab, Nx_in_regions, Nbus_in_regions,'mag');
    AA = cell(numel(Aang),1);
    % stack together and check for correct dimensions
%     A = stack_and_check(Aang, Amag, height(tab), number_of_buses_in_region, number_of_copy_buses_in_region);
    for i = 1:numel(Aang)
        AA{i} = [Aang{i};Amag{i}];
    end
end

% function A = stack_and_check(Aang, Amag, Nconsensus, number_of_buses_in_region, number_of_copy_buses_in_region)
%     assert(numel(Aang) == numel(Amag), 'inconsistent dimensions.');
%     A = Aang;
%     Nrows = 2*Nconsensus;
%     for i = 1:numel(Amag)
%         A{i} = [ Aang{i}; Amag{i} ];
%         
%         Ncopy = number_of_copy_buses_in_region(i);
%         Ncore = number_of_buses_in_region(i) - Ncopy;
%         Ncols = 4*Ncore + 2*Ncopy;
%         
%         assert(prod(size(A{i}) == [Nrows, Ncols]) == 1, 'inconsistent dimensions for consensus matrix in region %i', i);
%     end
% end

function A = build_consensus_matrix(tab, Nx_in_regions,Ngen_in_regions, Nshift)
    A = build_consensus_matrix_core(tab, Nx_in_regions,Ngen_in_regions, Nshift);
%     A = delete_copy_bus_p_q_entries(A, number_of_copy_buses_in_region);
end

function A = build_consensus_matrix_core(tab, Nx_in_regions,Nbus_in_regions, kind)
    kind = lower(kind);
    Nconsensus = height(tab);
%     assert(kind == 'ang' | kind == 'mag', 'kind %s is not supported (only `ang` or `mag`).');
    Nregions = numel(Nx_in_regions);
    A = cell(Nregions, 1);
    for i = 1:Nregions
        A{i} = sparse(Nconsensus, Nx_in_regions(i));
    end
    
    for i = 1:Nconsensus
        orig_sys = tab.orig_sys(i);
        copy_sys = tab.copy_sys(i);
        orig_bus = tab.orig_bus_local(i);
        copy_bus = tab.copy_bus_local(i);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% the following code (implictly) assumes that the state in each
        %%% region is stacked according to x = [vang, vmag, pnet, qnet],
        %%% hence some shifting might be necessary, depending on whether we
        %%% build consensus for the voltage angle or voltage magnitude.
        if kind == 'ang'
            Norig = 0;
            Ncopy = 0;
        elseif kind == 'mag'
            Norig = Nbus_in_regions(orig_sys);
            Ncopy = Nbus_in_regions(copy_sys);
        else
            error('kind %s is not supported', kind);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        orig_bus_entry = orig_bus + Norig;
        copy_bus_entry = copy_bus + Ncopy;
        
        A{orig_sys}(i, orig_bus_entry) = 1;
        A{copy_sys}(i, copy_bus_entry) = -1;
    end
end
% 
% function A = delete_copy_bus_p_q_entries(A, copy_buses)
%     for i = 1:numel(copy_buses)
%         entries = A{i};
%         [rows, cols] = size(A{i});
%         entries(:,cols:-1:cols-2*copy_buses(i)+1) = [];
%         A{i} = entries;
%     end
% end