function violation = compare_constraints_violation(problem, logg)
    state     = problem.state;
    pf        = problem.pf;          % constraints function from power flow
    bus_specs = problem.bus_specs;
    X         = logg.X;
    Y         = logg.Y;
    iter      = logg.iter;
    N_region  = numel(pf);
    N_previous_state = 0;
    AA = [problem.AA{:}];               % consensus matrix for global x
    violation.pf_norm     = [];
    violation.bus_norm    = [];
    violation.pf_percent     = [];
    violation.bus_percent    = [];
    violation.sytnax.region = [];
    violation.sytnax.pf     = [];
    violation.sytnax.bus    = [];    
    for i = 1:N_region
        N_current_state  = numel(state{i});
        n                = N_previous_state+1;               % start number
        m                = N_previous_state+N_current_state; % end number
        for j = 1:iter
            % compute violation in current iteration and region
            x_i                     = Y(n:m,j);
            violation.iter.pf(i,j)  = norm(pf{i}(x_i), inf);
            violation.iter.bus(i,j) = norm(bus_specs{i}(x_i), inf);
        end
        N_previous_state        = m;
        % violation at minimizer, j = iter
        pf_norm                 = pf{i}(x_i) .* pf{i}(x_i);
        bus_norm                = bus_specs{i}(x_i) .* bus_specs{i}(x_i);
        violation.pf_norm       = vertcat(violation.pf_norm,  pf_norm);
        violation.bus_norm      = vertcat(violation.bus_norm, bus_norm);
        violation.pf_percent    = vertcat(violation.pf_percent, pf_norm/violation.iter.pf(i,iter));
        violation.bus_percent   = vertcat(violation.bus_percent, bus_norm/violation.iter.bus(i,iter));
        % index, N_data = 2 * Nbus_core   
        N_data                  = numel(pf{i}(x_i));
        index                   = 1:N_data;
        violation.sytnax.region = vertcat(violation.sytnax.region,ones(N_data,1)*i);
        violation.sytnax.pf     = vertcat(violation.sytnax.pf,compose('g_{pf,%-d}',index)');
        violation.sytnax.bus    = vertcat(violation.sytnax.bus,compose('g_{bus,%-d}',index)');
        
%        violation.consensus     = logg.cons_violations(2:end);
%        assert(length(violation.consensus) == logg.iter)
    end
    violation_consensus        = max(abs(AA * X(:,1:iter)));
    violation_consensus(violation_consensus==0) = eps; % avoid 0 for logplot
    dual_feasibility           = max(abs(AA * (X(:,1:iter)-Y(:,1:iter))));
    dual_feasibility(dual_feasibility==0) = eps; % avoid 0 for logplot    
    violation.dual_feasibility = dual_feasibility;
    violation.consensus        = violation_consensus;
%      violation       = data_processing(violation);
%     plot_violation_results_table(violation, iter);
    plot_violation_results(violation);
end


function plot_violation_results(violation)
% plot the results
    iter_pf       = violation.iter.pf;
    iter_bus      = violation.iter.bus;
    pf_norm       = violation.pf_norm;
    bus_norm      = violation.bus_norm;
    pf_percent    = violation.pf_percent;
    bus_percent   = violation.bus_percent;
    consensus_vio = violation.consensus;
    dual_feasibility = violation.dual_feasibility;
    N_region = size(iter_pf, 1);
    iter     = size(iter_pf, 2);
    sytnax   = violation.sytnax;
    % limit setting
    Max      = max([iter_pf, iter_bus], [], 'all')*2;
    Min      = min([iter_pf, iter_bus], [], 'all')/2;        
    limit    = [1, iter,  Min, Max];
    % legend str setting

    for i = 1:N_region
        legendCell{i} = num2str(i,'Region %-d');
    end
    
%%  plot per iter
    figure('units','normalized','outerposition',[0.2 0.2 0.8 0.8])
%     subplot(3,1,1)
%     % violation of power flow
%     semilogy(iter_pf','Marker', 'x')
%     axis(limit)
%     set(gca, 'XTick', 1:iter)
%     xlabel('$\mathrm{Iteration}$','fontsize',12,'interpreter','latex')
%     ylabel('$\|g^{pf}_i(x_i)\|_{\infty}$','fontsize',12,'interpreter','latex')
%     legend(legendCell,'fontsize',12, 'interpreter','latex')
%     grid on
%     
%     subplot(3,1,2)
%     % violation of bus bus_specs
%     semilogy(iter_bus', 'Marker', 'x')
%     axis(limit)
%     set(gca, 'XTick', 1:iter)
%     xlabel('$\mathrm{Iteration}$','fontsize',12,'interpreter','latex')
%     ylabel('$\|g^{bus}_i(x_i)\|_{\infty}$','fontsize',12,'interpreter','latex')
%     legend(legendCell,'fontsize',12, 'interpreter','latex')
%     grid on
%     
%     subplot(3,1,3)
%     % consensus violation
%     semilogy([1:iter],consensus_vio, 'Marker', 'x')
%     axis(limit)
%     set(gca, 'XTick', 1:iter)
%     xlabel('$\mathrm{Iteration}$','fontsize',12,'interpreter','latex')
%     ylabel('Consensus violation','fontsize',12,'interpreter','latex')
%     grid on

%%

    subplot(4,1,1)
    % violation of power flow
    semilogy(iter_pf','Marker', 'x')
    axis(limit)
    set(gca, 'XTick', 1:iter)
    xlabel('$\mathrm{Iteration}$','fontsize',12,'interpreter','latex')
    ylabel('$\|g^{pf}_i(x_i)\|_{\infty}$','fontsize',12,'interpreter','latex')
    legend(legendCell,'fontsize',12, 'interpreter','latex')
    grid on
    
    subplot(4,1,2)
    % violation of bus bus_specs
    semilogy(iter_bus', 'Marker', 'x')
    axis(limit)
    set(gca, 'XTick', 1:iter)
    xlabel('$\mathrm{Iteration}$','fontsize',12,'interpreter','latex')
    ylabel('$\|g^{bus}_i(x_i)\|_{\infty}$','fontsize',12,'interpreter','latex')
    legend(legendCell,'fontsize',12, 'interpreter','latex')
    grid on
    
    subplot(4,1,3)
    % consensus violation
    semilogy([1:iter],consensus_vio, 'Marker', 'x')
    axis(limit)
    set(gca, 'XTick', 1:iter)
    xlabel('$\mathrm{Iteration}$','fontsize',12,'interpreter','latex')
    ylabel('Consensus violation','fontsize',12,'interpreter','latex')
    grid on
    
    subplot(4,1,4)
    % consensus violation
    semilogy([1:iter],dual_feasibility, 'Marker', 'x')
    axis(limit)
    set(gca, 'XTick', 1:iter)
    xlabel('$\mathrm{Iteration}$','fontsize',12,'interpreter','latex')
    ylabel('Dual Feasibility','fontsize',12,'interpreter','latex')
    grid on
%% plot per region
    plot_per_region(pf_norm,pf_percent,sytnax,'pf') 
    plot_per_region(bus_norm,bus_percent,sytnax,'bus') 
    plot_compare(pf_norm,bus_norm, sytnax)
end

function plot_per_region(pf_norm,pf_percent,sytnax,type)
    N_region = sytnax.region(end);
    figure('units','normalized','outerposition',[0.2 0.2 0.8 0.8])
    for i = 1:N_region
        % date processing in region i
        pf_norm_i = pf_norm(sytnax.region==i);
        pf_percent_i = pf_percent(sytnax.region==i);
        x_cell_i  = sytnax.(type)(sytnax.region==i);
        % find 5-largest number
        [pf_norm_i, idx] = maxk(pf_norm_i,5);
        pf_percent_i = pf_percent_i(idx);
        pf_percent_i = [pf_percent_i; 1-sum(pf_percent_i)];
        x_cell_i  = x_cell_i(idx);
        % add label
        bar_x     = reordercats(categorical(x_cell_i),x_cell_i);
        x_cell_i(end+1) = {'others'};
        pie_legend = x_cell_i;
        subplot(N_region,2,i*2-1)
        % violation of power flow
        bar(bar_x, pf_norm_i),set(gca,'yscale','log')
        ylim([pf_norm_i(end)/2, pf_norm_i(1)*2])
        grid on
        subplot(N_region,3,i*3)
        % violation of power flow
        x_cell_i = {x_cell_i, ''};
        pie(pf_percent_i)
        legend(pie_legend,'Location','eastoutside')
        grid on
    end    
end

function plot_compare(pf_norm,bus_norm,sytnax)
    N_region = sytnax.region(end);
    figure('units','normalized','outerposition',[0.2 0.2 0.8 0.8])
    for i = 1:N_region
        [~,~,nonzeros] = find([pf_norm;bus_norm]);
        max_data = max(nonzeros);       
        min_data = min(nonzeros);        
        % date processing in region i
        pf_norm_i = pf_norm(sytnax.region==i);
        % find 5-largest number
        bus_norm_i = bus_norm(sytnax.region==i);
        % add label
%         bar_x     = reordercats(categorical(x_cell_i),x_cell_i);
        % violation of power flow
        subplot(N_region,1,i)
        bar([pf_norm_i,bus_norm_i]),set(gca,'yscale','log')
        ylim([min_data/2 , max_data*2])
        title(compose('Region %-d',i))
        legend({'pf','bus'})
        grid on
    end    

end
% function violation = data_processing(violation)
%    % transfer to 'cell' 
%     region                   = cellstr(num2str(violation.sytnax.region, '%-d'));
%     violation.table.var_pf   = {'region','sytnax','residual','proportion'};
%     violation.table.var_bus  = violation.table.var_pf;
%     violation.table.var_cmp  = {'region','index_1','residual_1', 'index_2','residual_2','proportion'};
%     % preparing for `uitable()`function
%     str = {'pf','bus','cmp'};
%     N          = numel(str);
%     % table making
%     for i = 1:N
%         data_str = ['data_', str{i}];
%         var_str  = ['var_', str{i}];
%         if i < 3
%            [violation.table.(data_str),violation.idx{i}]  = make_data(region, violation.sytnax.(str{i}), violation.(str{i}));
%         else
%            [violation.table.(data_str),violation.idx{i}]  = make_data(region, violation.sytnax.pf, violation.pf, violation.sytnax.bus, violation.bus);
%         end
%         save_table(violation,str{i})
%     end
%     % bar making
%     for i = 1:N
%         
%     end
%     
% end

% function [data_out,idx] = make_data(region, sytnax_1, data_in_1, sytnax_2, data_in_2)
%     % make data to plot 1,2,3
%     if nargin < 4
%         % pf and bus
%         vector_to_sort = data_in_1;
%         Colomn_1 = cellstr(num2str(data_in_1,'%-4.3E'));
%         Colomn_2 = cellstr(num2str(100 * data_in_1 / sum(data_in_1), '%-4.2f%%'));
%         data = horzcat(region, sytnax_1, Colomn_1,Colomn_2);
%     else
%         % compare
%         vector_to_sort  = data_in_1+data_in_2;
%         Colomn_1 = cellstr(num2str(data_in_1,'%-4.3E'));
%         Colomn_2 = cellstr(num2str(data_in_2,'%-4.3E'));
%         Colomn_3 = cellstr(num2str(100 * vector_to_sort / sum(vector_to_sort), '%-4.2f%%'));
%         data = horzcat(region, sytnax_1, Colomn_1, sytnax_2, Colomn_2, Colomn_3);
%     end
%     % sort the data, descent
%     [~,idx]  = sort(vector_to_sort,'descend');
%     data_out = data(idx,:);
% end
% 
% 
% function plot_violation_results_table(violation,iter)
% % plot the results
%     iter_pf       = violation.iter.pf;
%     iter_bus      = violation.iter.bus;
%     % limit setting
%     Max      = max([iter_pf, iter_bus], [], 'all')*2;
%     Min      = min([iter_pf, iter_bus], [], 'all')/2;        
%     limit    = [1, iter+1,  Min, Max];
%     % legend str setting
%     N_region = size(iter_pf, 1);
%     for i = 1:N_region
%         legendCell{i} = num2str(i,'Region %-d');
%     end
%     
% %%  figure part  
%     figure('units','normalized','outerposition',[0.2 0.2 0.8 0.8])
%     subplot(3,1,1)
%     % violation of power flow
%     semilogy(iter_pf')
%     axis(limit)
%     xlabel('$\mathrm{Iteration}$','fontsize',12,'interpreter','latex')
%     ylabel('$||g^{pf}_i(x_i)||^2_2$','fontsize',12,'interpreter','latex')
%     legend(legendCell,'fontsize',12, 'interpreter','latex')
%     grid on
%     
%     subplot(3,1,2)
%     % violation of bus bus_specs
%     semilogy(iter_bus')
%     axis(limit)
%     xlabel('$\mathrm{Iteration}$','fontsize',12,'interpreter','latex')
%     ylabel('$||g^{bus}_i(x_i)||^2_2$','fontsize',12,'interpreter','latex')
%     legend(legendCell,'fontsize',12, 'interpreter','latex')
%     grid on
%     
%     subplot(3,1,3)
%     % comparison of two kinds of constraints
%     semilogy([1:iter],sum(iter_pf),[1:iter],sum(iter_bus))
%     axis(limit)
%     xlabel('$\mathrm{Iteration}$','fontsize',12,'interpreter','latex')
%     ylabel('$\mathrm{Violation\;of\;different\;constraints}$','fontsize',12,'interpreter','latex')
%     legend('$||g^{bus}_i(x_i)||^2_2$','$||g^{bus}_i(x_i)||^2_2$','fontsize',12,'interpreter','latex')
%     grid on
%     
% %%  table part
%     figure('units','normalized','outerposition',[0.2 0.2 0.8 0.8])
%     subplot(1,3,1),plot(3)
%     t = uitable('Data',violation.table.data_pf,'ColumnWidth',{60});
%     pos = get(subplot(1,3,1),'position');
%     title('Plot 1')
%     set(subplot(1,3,1),'yTick',[])
%     set(subplot(1,3,1),'xTick',[])
%     set(t,'units','normalized')
%     set(t,'position',pos)
%     set(t,'ColumnName',violation.table.var_pf)
%     
%     subplot(1,3,2),plot(3)
%     t = uitable('Data',violation.table.data_bus,'ColumnWidth',{60});
%     pos = get(subplot(1,3,2),'position');
%     title('Plot 2')
%     set(subplot(1,3,2),'yTick',[])
%     set(subplot(1,3,2),'xTick',[])
%     set(t,'units','normalized')
%     set(t,'position',pos)
%     set(t,'ColumnName',violation.table.var_bus)    
%     
%     subplot(1,3,3),plot(3)
%     t = uitable('Data',violation.table.data_cmp,'ColumnWidth',{60});
%     pos = get(subplot(1,3,3),'position');
%     title('Plot 3')
%     set(subplot(1,3,3),'yTick',[])
%     set(subplot(1,3,3),'xTick',[])
%     set(t,'units','normalized')
%     set(t,'position',pos)
%     set(t,'ColumnName',violation.table.var_cmp)    
% 
% end
% 
% function save_table(violation,str)
% % save table to a csv file
%     data_str = ['data_', str];
%     var_str  = ['var_', str];
%     filename = ['residual_',str,'.csv'];
%     tb       = cell2table(violation.table.(data_str),'VariableNames',violation.table.(var_str));
%     writetable(tb,filename);
% end