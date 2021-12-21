function error = deviation_violation_iter_plot(mpc, xval, logg, names) 
    for j = 1:logg.iter
            x      = logg.Y(:,j);
            x      = wrap_ang(x,mpc);  
            [Y, ~] = deal_solution(x, mpc, names);
            e      = table2array(compare_results(xval, Y));
            error(j) = max(e(:,2)); % norm-inf of all regions
    end
    logg.primal_feasibility(logg.primal_feasibility==0) =eps;
    iter_plot(error,logg.primal_feasibility(2:end));
end

function iter_plot(error, cons_violations)
    figure('Name','compare different initial points')
    subplot(2,1,1)
    semilogy(error)
    grid on
    xlabel('$\mathrm{Iteration}$','interpreter','Latex');
    ylabel('$||x^k-x^*||_2$','interpreter','Latex');
    lgd = legend('$0.01$','$0.1$','$1$','$3$','$10$','interpreter','Latex');
    title(lgd,'$||x_0-x^*||_2$','interpreter','Latex')
    
    subplot(2,1,2)
    semilogy(cons_violations)
    grid on
    xlabel('$\mathrm{Iteration}$','interpreter','Latex');
    ylabel('$||Ax-b||_{\infty}$ ','interpreter','Latex');
    lgd = legend('$0.01$','$0.1$','$1$','$3$','$10$','interpreter','Latex');
    title(lgd,'$||x_0-x^*||_2$','interpreter','Latex')

end


