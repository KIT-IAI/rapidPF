function res = ADMM_comparision_state_iterately(mpc_split, problem, xval, names)
    %% params setting for ADMM
    params.rho       = 1000;
    params.max_iter  = 100;
    params.tol       = 1e-4;
    params.rhoUpdate = false;
    %% alex
    [xsol_alex, xsol_alex_stacked, mpc_alex, loggX_alex] = solve_distributed_problem_with_aladin_admm(mpc_split, problem, names, params);
    %comparison_alex = compare_results(xval, xsol_alex)
    %% xinliang
    [xsol_xinliang, xsol_xinliang_stacked, mpc_xinlian, loggX_xinliang] = solve_distributed_problem_with_admm_xinliang(mpc_split, problem, names, params);
    %comparison_xinliang = compare_results(xval, xsol_xinliang)
    %% comparison in each iteration
    A     = horzcat(problem.AA{:});  % Ax - b = 0, centralized
    res = plotcomparison_iter(mpc_split,loggX_alex,loggX_xinliang, xval, A, names);
end
    
function res = plotcomparison_iter(mpc,logX1, logX2, xval, A, names)
    iter1 = size(logX1,2);
    iter2 = size(logX2,2);
    iter_min = min(iter1,iter2);
    res.alex.vio      = get_violation(logX1, A);
    res.xinliang.vio  = get_violation(logX2, A);
    res.diff_states   = state_diff_inf_norm(logX1,logX2);
    res.alex.error    = state_error_inf_norm(mpc, xval, logX1, names);
    res.xinliang.error  = state_error_inf_norm(mpc, xval, logX2, names);
    figure('Name','compare different ADMMs')
    subplot(3,1,1)
    semilogy(1:iter1, res.alex.vio, 1:iter2, res.xinliang.vio,'--');
    grid on
    xlabel('$\mathrm{Iteration}$','interpreter','Latex');
    ylabel('$||Ax-b||_{\infty}$ ','interpreter','Latex');
    legend('ADMMnew from Alex','ADMM from Xinliang')
    
    subplot(3,1,3)
    semilogy(1:iter_min, res.diff_states , '-o');
    grid on
    xlabel('$\mathrm{Iteration}$','interpreter','Latex');
    ylabel('$||x^k_{alex}-x^k_{xinliang}||_2$','interpreter','Latex');

    subplot(3,1,2)
    plot(1:iter1, res.alex.error, 1:iter2, res.xinliang.error,'--');
    grid on
    xlabel('$\mathrm{Iteration}$','interpreter','Latex');
    ylabel('$||x^k-x^*||_2$','interpreter','Latex');
    legend('ADMMnew from Alex','ADMM from Xinliang')
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

function diff = state_diff_inf_norm_old(x1, x2)
    iter1 = size(x1,2);
    iter2 = size(x2,2);
    if iter1==1
        % x1 is a vector: ref state by runpf
        x1 = repmat(x1, 1, iter2);
        iter1 = iter2;
    end
    iter = min(iter1, iter2);
    diff = [];
    for i=1:iter
        % remove copy node in order to compare with xval_stacked
        [~, x2] = deal_solution(x2(:,i), mpc, names);

        % calculate the diff in each iteration
        diff(i)  = norm(x1(:,i) - x2(:,i),inf);
    end
end

function diff = state_diff_inf_norm(x1, x2)
    % calculate the state diff of 2 Alg. in each iteration
    iter1 = size(x1,2);
    iter2 = size(x2,2);
    iter = min(iter1, iter2);
    diff = [];
    for i=1:iter
        % transfer cell to array of states in current iter
        x_1 = cell2mat(x1(:,i));
        x_2 = cell2mat(x2(:,i));
        diff(i)  = norm(x_1 - x_2,inf);
    end
end

function error = state_error_inf_norm(mpc, xval, x, names)
    % calculate the state error in each iteration
    iter = size(x,2);
    for i=1:iter
        % remove copy node in order to compare with xval_stacked
        [X, ~] = deal_solution(cell2mat(x(:,i)), mpc, names);
        e = table2array(compare_results(xval, X));
        error(i) = max(e(:,2));
    end
end
