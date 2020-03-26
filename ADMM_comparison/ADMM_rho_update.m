function [error, violation] = ADMM_rho_update(mpc, problem, xval, names)
    A   = horzcat(problem.AA{:});  % Ax - b = 0, centralized
    params.max_iter = 200;
    params.tol = 1e-4;
    params.rho = 2;
    params.rhoUpdate = true;
    [~, ~, ~, loggX, rho] = solve_distributed_problem_with_aladin_admm(mpc, problem, names, params);
    iter = size(loggX,2);
    for j = 1:iter
        % in j-th iteration
       [X, ~] = deal_solution(cell2mat(loggX(:,j)), mpc, names);
        e = table2array(compare_results(xval, X));
        % error: line - iteration, column - test
        error(j)     = max(e(:,2));
        violation(j) = get_violation(loggX(:,j), A);
    end
    plotresults(error, violation, rho)
end

function vio = get_violation(logX, A)
% violation in each iteration
    iter = size(logX,2);
    vio  = [];
    if iscell(logX)
        logX = cell2mat(logX);
    end
    for i = 1:iter
        vio(i) = norm(A*logX(:,i),inf);
    end
end

function plotresults(error, violation, rho)
    figure('Name','compare different rho')
    subplot(3,1,1)
    loglog(error)
    grid on
    xlabel('$\mathrm{Iteration}$','interpreter','Latex');
    ylabel('$||x^k-x^*||_2$','interpreter','Latex');
%    legend('$0.1$','$1$','$10$','$10^2$','$10^3$', '$10^4$','$10^5$','$10^6$','interpreter','Latex')

    subplot(3,1,2)
    loglog(violation)
    grid on
    xlabel('$\mathrm{Iteration}$','interpreter','Latex');
    ylabel('$||Ax-b||_{\infty}$ ','interpreter','Latex');
%    legend('$0.1$','$1$','$10$','$10^2$','$10^3$', '$10^4$','$10^5$','$10^6$','interpreter','Latex')

    
    subplot(3,1,3)
    loglog(rho)
    grid on
    xlabel('$\mathrm{Iteration}$','interpreter','Latex');
    ylabel('$\rho^k$ ','interpreter','Latex');
 %   legend('$0.1$','$1$','$10$','$10^2$','$10^3$', '$10^4$','$10^5$','$10^6$','interpreter','Latex')

end