function [error, violation] = ADMM_comparison_different_rho(mpc, problem, xval, names)
    rho = [0.1 1 10 100 1000 10000 1e5];
    A   = horzcat(problem.AA{:});  % Ax - b = 0, centralized
    params.max_iter = 5000;
    params.tol      = 1e-4;
    params.rhoUpdate = false;
    for i = 1: numel(rho)
        % i-th test
        params.rho = rho(i);
        [~, ~, ~, loggX] = solve_distributed_problem_with_aladin_admm(mpc, problem, names, params);
        iter = size(loggX,2);
        for j = 1:iter
            % in j-th iteration
           [X, ~] = deal_solution(cell2mat(loggX(:,j)), mpc, names);
            e = table2array(compare_results(xval, X));
            % error: line - iteration, column - test
            error(j,i)     = max(e(:,2));
            violation(j,i) = get_violation(loggX(:,j), A);
        end
    end
    plotresults(error, violation)
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

function plotresults(error, violation)
    figure('Name','compare different rho')
    subplot(2,1,1)
    loglog(error)
    grid on
    xlabel('$\mathrm{Iteration}$','interpreter','Latex');
    ylabel('$||x^k-x^*||_2$','interpreter','Latex');
    lgd = legend('$10^{-1}$','$10^0$','$10$','$10^2$','$10^3$', '$10^4$','$10^5$','interpreter','Latex');
    title(lgd,'$\rho$','interpreter','Latex')

    subplot(2,1,2)
    loglog(violation)
    grid on
    xlabel('$\mathrm{Iteration}$','interpreter','Latex');
    ylabel('$||Ax-b||_{\infty}$ ','interpreter','Latex');
    lgd = legend('$10^{-1}$','$10^0$','$10$','$10^2$','$10^3$', '$10^4$','$10^5$','interpreter','Latex');
    title(lgd,'$\rho$','interpreter','Latex');
end