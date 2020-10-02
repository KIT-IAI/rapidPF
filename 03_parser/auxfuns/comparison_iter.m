function comparison_iter(violation_1, violation_2)
    data_max = max([violation_1, violation_2]);
    data_min = min([violation_1, violation_2]);
    limit    = [data_min/2, data_max*2];
    figure('units','normalized','outerposition',[0.2 0.2 0.8 0.8])
    % violation of power flow
    loglog([violation_1 ; violation_2]')
    ylim(limit)
    xlabel('$\mathrm{Iteration}$','fontsize',12,'interpreter','latex')
    ylabel('$\mathrm{violation\;of\; consensus \;constraints}$','fontsize',12,'interpreter','latex')
    legend('ADMM','classic ADMM','fontsize',12,'interpreter','latex')
    grid on
end