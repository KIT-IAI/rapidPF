function ADMM_initial_point_near_ref(mpc, problem, xval, names, x_ref)
    N_region = numel(problem.zz0);
    A        = horzcat(problem.AA{:});  % Ax - b = 0, centralized
    % params setting
    alpha             = [ 1e-2, 0.1, 1, 3, 10];
    params.max_iter = 10000;
    params.tol     = 1e-4;
    params.rho     = 1000;
    params.rhoUpdate   = false;
    x0             = problem.zz0;
    for i = 1:numel(alpha)
        for j = 1:N_region
            dx     = randn(size(x0{j}));
            dx     = dx/norm(dx,2)/sqrt(numel(N_region));
            x0{j} = x_ref{j} + dx*alpha(i);
        end
        
        problem.zz0 = x0;
        [~, ~, ~, loggX] = solve_distributed_problem_with_aladin_admm(mpc, problem, names, params);

        iter = size(loggX,2);
        for j = 1:iter
            [X, ~] = deal_solution(cell2mat(loggX(:,j)), mpc, names);
            e = table2array(compare_results(xval, X));
            % error: line - iteration, column - test
            error(j,i)     = max(e(:,2)); % norm-inf of all regions
            violation(j,i) = get_violation(loggX(:,j), A);
        end
    end
    plotresults(error,violation)
end

function plotresults(error, violation)
    figure('Name','compare different initial points')
    subplot(2,1,1)
    loglog(error)
    grid on
    xlabel('$\mathrm{Iteration}$','interpreter','Latex');
    ylabel('$||x^k-x^*||_2$','interpreter','Latex');
    lgd = legend('$0.01$','$0.1$','$1$','$3$','$10$','interpreter','Latex');
    title(lgd,'$||x_0-x^*||_2$','interpreter','Latex')
    
    subplot(2,1,2)
    loglog(violation)
    grid on
    xlabel('$\mathrm{Iteration}$','interpreter','Latex');
    ylabel('$||Ax-b||_{\infty}$ ','interpreter','Latex');
    lgd = legend('$0.01$','$0.1$','$1$','$3$','$10$','interpreter','Latex');
    title(lgd,'$||x_0-x^*||_2$','interpreter','Latex')

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