function [P_pf_from, Q_pf_from, gen_sum_per_regions] = compare_power_flow_between_regions(mpc,conn, regions, conn_array)
    [F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
    gen        = mpc.gen;
    branch     = mpc.branch; 
    N_regions  = numel(regions);
    N_conn     = numel(conn); % the number of connections between regions    
    connection = [];
    for i = 1:N_conn
        connection = [ connection; conn{i}];
    end
    N_connection = size(connection,1);
    
    %% power flow between regions
    P_pf_from    = [];
    Q_pf_from    = [];
    for i = 1:N_connection
        idx = find((branch(:,1)==connection(i,1))&(branch(:,2)==connection(i,2)));
        P_pf_from = [P_pf_from; branch(idx, PF)];
        Q_pf_from = [Q_pf_from; branch(idx, QF)];
                
%         if i == 1
%             G = digraph(conn_array(1,1),conn_array(1,2));
%         else
%             if (conn_array(i,1)~= conn_array(i-1,1))||(conn_array(i,2)~= conn_array(i-1,2))
%                 G = addedge(G, conn_array(i,1),conn_array(i,1));
%             end
%         end
    end
    %% gen sum per regions
    gen_sum_per_regions = [];
    for i = 1:N_regions
        idx = ismember(gen(:,1), regions{i});
        gen_sum_per_regions = [gen_sum_per_regions; sum(gen(idx, 2))];
    end
    figure
    subplot(1,2,1)
    bar([gen_sum_per_regions;P_pf_from])
    xlabel('$\mathrm{Region}$','fontsize',12,'interpreter','latex')
    ylabel('$\mathrm{Real\;Power}[MVA]$','fontsize',12,'interpreter','latex')
    set(gca,'XTickLabel',{'1','2','3','1-2','2-3','2-3'});

    subplot(1,2,2)
    conn_array = table2array(conn_array);
    s = conn_array(:,1);
    t = conn_array(:,2);
    G = digraph(s,t);
    plot(G)
end
