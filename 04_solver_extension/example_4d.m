%-----------------------------------------------------------------------
%
% Minimise    f
%
% subject to      -0.5 <= x1 <=  INFTY
%                   -2 <= x2 <=  INFTY
%                    0 <= x3 <=  2
%                   -2 <= x4 <=  2
%                         g1 ==  1
%               -INFTY <= g2 <= -1
%                  2.5 <= g3 <=  5
%
% where         f (x1,x2,x3,x4) = x1^2 + 2 x2^2 - x3
%               g1(x1,x2,x3,x4) = x1^2 + x3^2 + x1x3
%               g2(x1,x2,x3,x4) = x3 - x4
%               g3(x1,x2,x3,x4) = x2 + x4
%
% Optimal solution
%                     x*  = (0, 0.5, 1, 2)
%                   f(x*) = -0.5
%                   g(x*) = (1, -1, 2.5)
%
%-----------------------------------------------------------------------
function example_4d

% Convenience
% wData = worhpdataset();

% Specify number of variables and constraints
% as those values are never passed to Worhp
% it is not necessary to specify these here
% but may still be useful for initialisation
% wData.n = 4;
% wData.m = 0;

% Box constraints for X
wData.XL = [-2 -2];
wData.XU = [2 2];

% Define bounds for G
% wData.GL = [1 -inf 2.5];
% wData.GU = [1 -1 5];
wData.GL = 0;
wData.GU = 0;


% Initial estimates for X and Lambda
wData.xInit = [2 2];
wData.lambdaInit = zeros(size(wData.XL));
% and for Mu
wData.muInit = zeros(size(wData.GL));
% Initialise sparsity structure of derivates
% according to the WORHP user manual (Coordinate Storage format)
wData.DFrow = int32([1 2]);
wData.DGrow = int32([1 1]);
wData.DGcol = int32([1 2]);
wData.HMrow = int32([2 1 2]);
wData.HMcol = int32([1 1 2]);
wData.param = 'worhp.xml';

% The callback functions.
wCallback.f           = @objective;
wCallback.g           = @constraints;
wCallback.df          = @gradient;
wCallback.dg          = @jacobian;
wCallback.hm          = @hessian;

% Call the solver
[xFinal lambdaFinal muFinal solverstatus] = worhp(wData, wCallback);

disp('Final x values')
disp(xFinal)
disp('Final multipliers (general constraints)')
disp(muFinal)
disp('Final multipliers (box constraints)')
disp(lambdaFinal)

% solverstatus contains:
% - major-, minor-, refine-iter
% - termination state

function f = objective(x)
    f = (1*(x(2)-x(1)^2)^2+(1-x(1))^2);


function g = constraints(x)
    g = 0;
    
function df = gradient(x)
    df = [4*x(1)^3-4*x(1)*x(2) + 2*x(1)-2; 2*(x(2)-x(1)^2)];
    
function dg = jacobian(x)
    dg = [0, 0];
    
function hm = hessian(x, mu, scale)
    hm = [-4*x(1); 12*x(1)^2 - 4*x(2)+2;  -2];
        