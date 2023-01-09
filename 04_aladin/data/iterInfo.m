classdef iterInfo
    % record information in iterations
    properties
        iter           int16  {mustBeNumeric}   % current iteration
        X                     {mustBeNumeric}   % x vector for all iter
        Y                     {mustBeNumeric}   % y vector for all iter
        Z                     {mustBeNumeric}   % old vector - previous iter
        lam                   {mustBeNumeric}   % dual vector for consensus constraints
        kappa                                   % dual vector for equality & inequality constraints
        rho            double {mustBeNumeric}   % local penalty parameter
        mu             double {mustBeNumeric}   % global penalty parameter
        computing_time double {mustBeNumeric}   % total computing time
        et
        delta                                     
        local_steplength   double {mustBeNumeric}   % steplength of local NLP
        global_steplength  double {mustBeNumeric}   % steplength of global QP
        primal_feasibility double {mustBeNumeric}   % steplength of local NLP
        dual_feasibility   double {mustBeNumeric}   % steplength of global QP
    end
    
    methods
        function obj = iterInfo(iter_max,Nx,Nlam,Nregion)
        %% constructor with maximal iteration and dimension of variables
            if nargin>1
                obj.X   = zeros(Nx,iter_max);
                obj.Y   = zeros(Nx,iter_max);
                obj.Z   = zeros(Nx,iter_max);
                if nargin >2
                    obj.lam    = zeros(Nlam,iter_max);
                end
            end
            % initial data format
            obj.iter              = 1;
            obj.delta             = zeros(iter_max,1);
            obj.rho               = zeros(iter_max,1);
            obj.mu                = zeros(iter_max,1);
            obj.local_steplength  = zeros(iter_max,1);
            obj.global_steplength = zeros(iter_max,1);
            obj.primal_feasibility = zeros(iter_max,1);
            obj.dual_feasibility  = zeros(iter_max,1);
            obj.et.local          = zeros(Nregion, iter_max);
            obj.et.global         = zeros(iter_max,1);
            obj.et.total          = zeros(iter_max,1);
        end
        
        function obj = post_loop_dataprocessing(obj)
        %% reduce dimension of iterInfo after Aladin loop
        % remove zeros column if converge before maxiter
            if isempty(obj.iter)
                warning('iterative record error')
            else
                % reduce dimension                
                idx         = 1:obj.iter;
                obj.mu      = obj.mu(idx);
                obj.rho     = obj.rho(idx);
                obj.delta   = obj.delta(idx);
                obj.et.global = obj.et.global(idx);
                obj.et.total = obj.et.total(idx);
                obj.local_steplength    = obj.local_steplength(idx);
                obj.global_steplength   = obj.global_steplength(idx);
                obj.primal_feasibility  = obj.primal_feasibility(idx);
                obj.dual_feasibility    = obj.dual_feasibility(idx);                
                if ~isempty(obj.X) && ~isempty(obj.Y) && ~isempty(obj.Z) && ~isempty(obj.lam)
                    obj.X      = obj.X(:,idx);
                    obj.Y      = obj.Y(:,idx);
                    obj.Z      = obj.Z(:,idx);
                    obj.lam    = obj.lam(:,idx);
                    obj.et.local = obj.et.local(:,idx);
                end
                obj.computing_time = sum(obj.et.total);
            end
        end
        
        function plot_iter_info(obj)
            %% plot data
            figure('Name','Iter Info','Position',[200,200, 1000, 400])
            subplot(1,2,1)
            xlimit = [0, obj.iter+1];
            ylimit = [1e-16,1e3];
            % violation of power flow
            obj.local_steplength(obj.local_steplength==0)=1e-15;
            obj.global_steplength(obj.global_steplength==0)=1e-15;
            semilogy([1:obj.iter],[obj.local_steplength,obj.global_steplength]', '*')
            xlim(xlimit)
            ylim(ylimit)
            xlabel('$\mathrm{Iteration}$','fontsize',12,'interpreter','latex')
            ylabel('$\mathrm{Steplength}$','fontsize',12,'interpreter','latex')
            legend({'local steplength','global steplength'},'fontsize',12, 'interpreter','latex')
            grid on

            subplot(1,2,2)
            xlimit = [0, obj.iter+1];
            % violation of power flow
            obj.primal_feasibility(obj.primal_feasibility==0)=1e-15;
            obj.dual_feasibility(obj.dual_feasibility==0)=1e-15;
            semilogy([1:obj.iter],[obj.primal_feasibility,obj.dual_feasibility]', 'x--')
            xlim(xlimit)
            ylim(ylimit)            
            xlabel('$\mathrm{Iteration}$','fontsize',12,'interpreter','latex')
            ylabel('$\mathrm{Termination\;Condition}$','fontsize',12,'interpreter','latex')
            legend({'Primal Feasibility','Dual Feasibility'},'fontsize',12, 'interpreter','latex')
            grid on
        end
    
        function plot_distance(obj,xopt)
            %% plot deviation of primal variables
            figure('Name','Iter Info','Position',[200,200, 1000, 400])
            subplot(1,3,1)
            xlimit = [0, obj.iter+1];
            ylimit = [1e-16,1e3];
            for i= 1: obj.iter
                dz(i) = norm(obj.Z(:,i)-xopt,inf);
                dy(i) = norm(obj.Y(:,i)-xopt,inf);
                dx(i) = norm(obj.X(:,i)-xopt,inf);
            end
            % violation of power flow
            obj.local_steplength(obj.local_steplength==0)=1e-15;
            obj.global_steplength(obj.global_steplength==0)=1e-15;
            semilogy([1:obj.iter],dz, '*')
            xlim(xlimit)
            ylim(ylimit)
            xlabel('$\mathrm{Iteration}$','fontsize',12,'interpreter','latex')
            ylabel('$||x^{old}-x^*||_\infty$','fontsize',12,'interpreter','latex')
            grid on
            subplot(1,3,2)
            xlimit = [0, obj.iter+1];
            ylimit = [1e-16,1e3];
            % violation of power flow
            obj.local_steplength(obj.local_steplength==0)=1e-15;
            obj.global_steplength(obj.global_steplength==0)=1e-15;
            semilogy([1:obj.iter],dy, '*')
            xlim(xlimit)
            ylim(ylimit)
            xlabel('$\mathrm{Iteration}$','fontsize',12,'interpreter','latex')
            ylabel('$||y-x^*||_\infty$','fontsize',12,'interpreter','latex')
            grid on
            subplot(1,3,3)
            xlimit = [0, obj.iter+1];
            ylimit = [1e-16,1e3];
            % violation of power flow
            obj.local_steplength(obj.local_steplength==0)=1e-15;
            obj.global_steplength(obj.global_steplength==0)=1e-15;
            semilogy([1:obj.iter],dx, '*')
            xlim(xlimit)
            ylim(ylimit)
            xlabel('$\mathrm{Iteration}$','fontsize',12,'interpreter','latex')
            ylabel('$||x^+-x^*||_\infty$','fontsize',12,'interpreter','latex')
            grid on
        end
    end

end

