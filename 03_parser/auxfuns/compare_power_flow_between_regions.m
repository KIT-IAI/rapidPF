function [tab_power,table_connection] = compare_power_flow_between_regions(mpc,conn, regions, conn_array)
    [F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
    gen        = mpc.gen;
    branch     = mpc.branch; 
    connection = [];
    trafo_region  = table2array(conn_array);
    trafo_from_to = vertcat(conn{:});
    N_conn     = size(trafo_from_to,1); % the number of connections between regions    
    N_regions  = numel(regions);

    
     
    %% power flow via connection
    from_region = [];
    to_region   = [];
    N_conn_region = [];
    direction   = [];
    record      = ones(N_conn,1);  % record of undo idx of connection
    pointer     = 1;
    edge_label  = [];
    pf   = [];
    while pointer > 0
        % find idx of connection array
        idx=ismember(trafo_region(:,1),trafo_region(pointer,1))...
            &ismember(trafo_region(:,2),trafo_region(pointer,2)); % find the same connections
        record(idx) = 0;     % mark all same connection as `done`
        % from region and to region
        from_region = [from_region;trafo_region(pointer,1)];
        to_region   = [to_region;trafo_region(pointer,2)];
        % find idx of global branch-data
        idx_branch  = ismember(branch(:,1),trafo_from_to(idx,1)) ...
            &ismember(branch(:,2),trafo_from_to(idx,2)); 
        % power flow along connections between these 2 regions
        pf_branch   = branch(idx_branch, PF);
        % negative value: change direction
        if pf_branch<0
            from_region(end) = trafo_region(pointer,2);
            to_region(end)   = trafo_region(pointer,1);
        end
        pf = [pf; abs(sum(pf_branch))];
        % number of connections between these 2 regions
        N_conn_region      = [N_conn_region;sum(idx)];
        % edge label
        str =  compose("%5.2f MW - %d Trafo",abs(sum(pf_branch)),sum(idx));
        edge_label = [edge_label;str];
        % find next undo connection 
        pointer = find(record,1);
    end
       
    
    %% power sum per regions
    gen_sum_per_regions = [];
    pf_out_per_regions  = [];
    pf_in_per_regions   = [];    
    
    for i = 1:N_regions
        % power generated in the region
        idx_gen = ismember(gen(:,1), regions{i});
        gen_sum_per_regions = [gen_sum_per_regions; sum(gen(idx_gen, 2))];
        % power flow out of the region 
        idx_out_conn    = ismember(trafo_region(:,1), i); % idx of connection array
        
        idx_out_branch  = ismember(branch(:,1),trafo_from_to(idx_out_conn,1)) ...
            &ismember(branch(:,2),trafo_from_to(idx_out_conn,2)); % idx of branch data
        pf_region       = branch(idx_out_branch, PF);         % power flow out of this region
        % power flow into the region
        idx_in_conn  = ismember(trafo_region(:,2), i);
        idx_in_branch  = ismember(branch(:,1),trafo_from_to(idx_in_conn,1)) ...
            &ismember(branch(:,2),trafo_from_to(idx_in_conn,2)); % idx of branch data
        pt_region       = branch(idx_in_branch, PT);         % power flow into this region
        % sum power in/out
        p_out = - sum(pf_region(pf_region>0)) - sum(pt_region(pt_region>0));
        p_in  = - sum(pf_region(pf_region<0)) - sum(pt_region(pt_region<0));
        pf_out_per_regions = [pf_out_per_regions; p_out];
        pf_in_per_regions  = [pf_in_per_regions; p_in];
    end

    
    
    figure
    subplot(1,2,1)
    bar([gen_sum_per_regions, pf_in_per_regions, pf_out_per_regions]/1000)
    legend({'$\mathrm{Generator}$','$\mathrm{pf_{in}}$','$\mathrm{pf_{out}}$'},'fontsize',12,'interpreter','latex');
    xlabel('$\mathrm{Region}$','fontsize',12,'interpreter','latex')
    ylabel('$\mathrm{Real\;Power}[10^3 MV]$','fontsize',12,'interpreter','latex')
  
    subplot(1,2,2)

    G = digraph(from_region,to_region);
    h = plot(G);
    h.EdgeLabel = edge_label;
    h.LineWidth = 2;
    h.ArrowSize = 15;
    h.NodeFontSize = 9;
    h.EdgeFontSize = 9;
    
    colormap jet
    h.EdgeCData = pf;
    colorbar;
    
    %% make table
    % active power
    regions = [1:N_regions]';
    tab_power = table(regions, gen_sum_per_regions, pf_in_per_regions, pf_out_per_regions);
    tab_power.Properties.Description = 'Active power flow into/out of regions';
    tab_power.Properties.VariableNames = {'Region', 'Generator[MW]', 'Power Flow(in)[MW]','Power Flow(out)[MW]'};
    
    % region topology
    table_connection = table(from_region,to_region,N_conn_region,pf);
    table_connection.Properties.Description = 'Active power flow between regions';
    table_connection.Properties.VariableNames = {'From Region', 'To Region', 'Trafos number','Power flow via Trafos[MW]'};
    
    
    
end
