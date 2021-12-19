classdef AladinOption
    %Options for ALADIN toolbox
    %   including parameters and suboptions for local NLPs and global QP
    %   default setting: iter_max = 20
    %                    tol      = 1e-6
    %                    mu0      = 1e3;
    %                    rho0     = 1e2;  
    properties
        problem_type char {mustBeMember(problem_type,{'general','feasibility', 'least-squares'})} = 'general' % problem type
        constrained  char {mustBeMember(constrained,{'none','equality', 'inequality'})} = 'none' % problem type
        iter_max   int16     = 20             % max iterations
        tol        double    = 1e-6           % tolerence
        mu0        double    = 1e3            % penalty parameter in global step
        rho0       double    = 1e2            % penalty parameter in local step
        iter_plot  logical   = true           % plot iter convergence 
        nlp        NLPoption = NLPoption          % options for solving local NLPs
        qp         QPoption  = QPoption                 % options for solving global QP
        active_set logical   = true          
    end
    
    methods
        function obj = AladinOption(option)
            %ALADINOPTION Construct an option obj of ALADIN algorithm
            if nargin>0
                obj = option;
            end
        end
    end
end

