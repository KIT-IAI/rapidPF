% create consensus in complex voltage at copy buses

function A = createAis(copy_bus_information, number_of_buses_in_region, number_of_copy_buses_in_region)
    N_regions = numel(number_of_buses_in_region);
    N_consensus = 2*size(copy_bus_information, 1); % consensus in voltage phasors

    A = cell(N_regions, 1);
    for i = 1:N_regions
        A{i} = sparse(N_consensus, 4*number_of_buses_in_region(i));   
    end

    row_counter = 0;

    for i = 1:size(copy_bus_information, 1)
        from_sys = copy_bus_information(i,1);
        from_bus = copy_bus_information(i,2);

        to_sys = copy_bus_information(i,3);
        to_bus = copy_bus_information(i,4);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% the following code (implictly) assumes that the state in each
        %%% region is stacked according to x = [vang, vmag, pnet, qnet]
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        A{from_sys}((row_counter+1):(row_counter+2), [from_bus, number_of_buses_in_region(from_sys)+from_bus]) =  speye(2);  
        A{to_sys}((row_counter+1):(row_counter+2), [to_bus, number_of_buses_in_region(to_sys)+to_bus]) = -speye(2);

        row_counter = row_counter + 2;
    end
    A = delete_copy_bus_p_q_entries(A, number_of_copy_buses_in_region);
end

function A = delete_copy_bus_p_q_entries(A, copy_buses)
    for i = 1:numel(copy_buses)
        entries = A{i};
        [rows, cols] = size(A{i});
        entries(:,cols:-1:cols-2*copy_buses(i)+1) = [];
        A{i} = entries;
    end
end

