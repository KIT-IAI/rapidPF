function [options, app] = plot_options
    % Create UIFigure and hide until all components are created
    app.UIFigure = uifigure;
    app.UIFigure.Position = [100 100 462 291];
    app.UIFigure.Name = 'UI Figure';

    % Create OptionMenu
    app.OptionMenu = uimenu(app.UIFigure);
    app.OptionMenu.Text = 'Option';

    % Create Menu2
    app.Menu2 = uimenu(app.UIFigure);
    app.Menu2.Text = 'Menu2';

    % Create ProblemTypeButtonGroup
    app.ProblemTypeButtonGroup = uibuttongroup(app.UIFigure);
    app.ProblemTypeButtonGroup.Title = 'Problem Type';
    app.ProblemTypeButtonGroup.Position = [33 114 164 75];

    % Create FeasibilityButton
    app.FeasibilityButton = uiradiobutton(app.ProblemTypeButtonGroup);
    app.FeasibilityButton.Text = 'Feasibility';
    app.FeasibilityButton.Position = [15 28 75 22];

    % Create LeastSquaresButton
    app.LeastSquaresButton = uiradiobutton(app.ProblemTypeButtonGroup);
    app.LeastSquaresButton.Text = 'Least-Squares';
    app.LeastSquaresButton.Position = [15 7 100 22];
    app.LeastSquaresButton.Value = true;

    
    % Create CasefileDropDownLabel
    app.CasefileDropDownLabel = uilabel(app.UIFigure);
    app.CasefileDropDownLabel.HorizontalAlignment = 'right';
    app.CasefileDropDownLabel.Position = [33 243 49 22];
    app.CasefileDropDownLabel.Text = 'Casefile';

    % Create CasefileDropDown
    app.CasefileDropDown = uidropdown(app.UIFigure);
    app.CasefileDropDown.Items = {'test','53-I','53-II',...
        '418-1','418-3','418-5','418-8','418-10',...
        '300X3(infesible)', '118X3',  '118X7', '118X8','118X10', ...
        '1654-1','1654-3','1654-5','1654-8','1654-10','1654-12',...
        '1654-16','1654-20','1654-25','1654-30',...
        '2708-1', '1354X3', '1354X3+300X2'};
    app.CasefileDropDown.Position = [33 222 164 22];
    app.CasefileDropDown.Value = 'test';

    % Create AlgorithmButtonGroup
    app.AlgorithmButtonGroup = uibuttongroup(app.UIFigure);
    app.AlgorithmButtonGroup.Title = 'Algorithm';
    app.AlgorithmButtonGroup.Position = [33 25 164 74];

    % Create ADMMButton
    app.ADMMButton = uiradiobutton(app.AlgorithmButtonGroup);
    app.ADMMButton.Text = 'ADMM';
    app.ADMMButton.Position = [15 26 59 22];

    % Create ALADINButton
    app.ALADINButton = uiradiobutton(app.AlgorithmButtonGroup);
    app.ALADINButton.Text = 'ALADIN';
    app.ALADINButton.Position = [15 5 65 22];
    app.ALADINButton.Value = true;


    % Create GSKEditFieldLabel
    app.GSKEditFieldLabel = uilabel(app.UIFigure);
    app.GSKEditFieldLabel.HorizontalAlignment = 'right';
    app.GSKEditFieldLabel.Position = [255 222 26 22];
    app.GSKEditFieldLabel.Text = 'GSK';

    % Create GSKEditField
    app.GSKEditField = uieditfield(app.UIFigure, 'numeric');
    app.GSKEditField.Position = [310 222 100 22];
    app.GSKEditField.Value = 0;

    % Create SolverButtonGroup
    app.SolverButtonGroup = uibuttongroup(app.UIFigure);
    app.SolverButtonGroup.Title = 'Solver';
    app.SolverButtonGroup.Position = [255 62 164 127];

    % Create CasADiButton
    app.CasADiButton = uiradiobutton(app.SolverButtonGroup);
    app.CasADiButton.Text = 'CasADi';
    app.CasADiButton.Position = [11 81 63 22];

    % Create fminconButton
    app.fminconButton = uiradiobutton(app.SolverButtonGroup);
    app.fminconButton.Text = 'fmincon';
    app.fminconButton.Position = [11 59 65 22];
    app.fminconButton.Value = true;

    % Create fminuncButton
    app.fminuncButton = uiradiobutton(app.SolverButtonGroup);
    app.fminuncButton.Text = 'fminunc';
    app.fminuncButton.Position = [11 37 65 22];

    % Create worhpButton
    app.worhpButton = uiradiobutton(app.SolverButtonGroup);
    app.worhpButton.Text = 'worhp';
    app.worhpButton.Position = [11 16 65 22];

%    Create runButton
    runButton = uibutton(app.UIFigure, 'push',...
        'Text', 'Run',...
        'FontWeight', 'bold',...
        'Position', [310 25 100 22], ...
        'ButtonPushedFcn', @(runButton,event)runButtonPushed(app));
    
    uiwait(app.UIFigure)
    % casefile
    options.casefile = string(app.CasefileDropDown.Value);

    % generation shift key
    options.gsk = double(app.GSKEditField.Value);

    % problem type
    if app.FeasibilityButton.Value == true
        options.problem_type = 'feasibility';
    elseif app.LeastSquaresButton.Value == true
        options.problem_type = 'least-squares';
    end

    % algorithm
    if app.ADMMButton.Value == true
        options.algorithm = 'admm';
    elseif app.ALADINButton.Value == true
        options.algorithm = 'aladin';
    end

    % solver
    if app.CasADiButton.Value == true
        options.solver = 'Casadi+Ipopt';
    elseif app.fminconButton.Value == true
        options.solver = 'fmincon';
    elseif app.fminuncButton.Value == true
        options.solver = 'fminunc';
    elseif app.worhpButton.Value == true 
        options.solver = 'worhp';
    end    
end            
function runButtonPushed(app)
    uiresume(app.UIFigure)
end