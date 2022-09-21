function [xopt, logg, flag] = run_aladin_algorithm(nlps,x0,lam0,A,b,option)
    %  initialize algorithm, run ALADIN-loop    
    tic
    xi     = x0;
    lam    = lam0;
    % initialize ALADIN algorithm
    aladin    = StartupALADIN(nlps,x0,A,b,option);
    %  main loop of ALADIN algorithm
    flag   = false;
    while aladin.logg.iter <=aladin.option.iter_max && ~flag
%         fprintf('\nstart iteration %d\n',aladin.logg.iter)
        % 1. solve local NLPs
        [yi,sensitivities]           = aladin.local_step(xi,lam);
        % 2. check termination condition
        [flag, res_consensus, aladin.logg]   = aladin.check_termination_condition(xi,yi);
        % 3. solve global QP
        [dy,dlam] = aladin.global_step(sensitivities,lam,res_consensus);
        % 4. update primal and dual variables
        [xi, lam, aladin.logg] = aladin.primal_dual_update(yi,dy,lam,dlam);
        % 5. terminate when trap in the loop, local&global step repeated themselves
        if aladin.logg.iter>1 && ~flag
            flag                             = aladin.check_trap_in_loop;
        end
%         norm(lam,2)
%         lam = zeros(size(lam));
        % naive updating pernalty parameters
        aladin.logg.mu(aladin.logg.iter+1)   = aladin.logg.mu(aladin.logg.iter);
        aladin.logg.rho(aladin.logg.iter+1)  = aladin.logg.rho(aladin.logg.iter);      
        aladin.logg.iter = aladin.logg.iter + 1;
    end
    aladin.logg.iter = aladin.logg.iter - 1;
%     if flag == 1
%         fprintf('\nprimal and dual feasibility satisfied at %d \n',aladin.logg.iter)
%     elseif flag ==2
%         fprintf('\nterminate due to trap in ALADIN loop at %d \n',aladin.logg.iter)
%     else
%         fprintf('\nterminate due to reach maximal iterations %d \n',aladin.logg.iter)
%     end
    xopt = vertcat(yi{:});
    aladin.logg.computing_time = toc;
%     fprintf('runing time of ALADIN algorithm: %6.3f [s]\n',aladin.logg.computing_time)
    logg = aladin.logg;
    % reduce dim of logg
    if logg.iter>aladin.option.iter_max 
        logg.iter=aladin.option.iter_max;
    end
    logg = logg.post_loop_dataprocessing;
    % plot iter info
    if aladin.option.iter_plot
        logg.plot_iter_info;
    end
end