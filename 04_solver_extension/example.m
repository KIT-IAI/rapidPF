%-----------------------------------------------------------------------
%
%  Minimize    f
%
%  subject to       -5  <= x1 <= 5
%                   -5  <= x2 <= 5
%                -INFTY <= g1 <= 1
%                -INFTY <= g2 <= 0
%
%  where         f (x1,x2) = x1^2 - x2^2
%                g1(x1,x2) = x1^2 + x2^2
%                g2(x1,x2) = x1   - x2
%
%  Optimal solution
%                      x*  = (0,1)
%                    f(x*) = -1
%                    g(x*) = (1,-1)
%
%-----------------------------------------------------------------------
function example

% Convenience
% wData = worhpdataset();

% Specify number of variables and constraints
% as those values are never passed to Worhp
% it is not necessary to specify these here
% but may still be useful for initialisation
%wData.n = 2;
%wData.m = 2;

% Box constraints for X
wData.XL = [-5 -5];
wData.XU = [5 5];

% Define bounds for G
wData.GL = [-inf -inf];
wData.GU = [1 0];

% Initial estimates for X and Lambda
wData.xInit = [0 5];
wData.lambdaInit = zeros(size(wData.XL));
% and for Mu
wData.muInit = zeros(size(wData.GL));
% Initialise sparsity structure of derivates
% according to the WORHP user manual (Coordinate Storage format)
wData.DFrow = int32([1 2]);
wData.DGrow = int32([1 2 1 2]);
wData.DGcol = int32([1 1 2 2]);
wData.HMrow = int32([1 2]);
wData.HMcol = int32([1 2]);
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
    f = (x(1)*x(1) - x(2)*x(2));


function g = constraints(x)
    g = [x(1)*x(1) + x(2)*x(2); x(1) - x(2)];
    
function df = gradient(x)
    df = [2 * x(1); -2 * x(2)];
    
function dg = jacobian(x)
    dg = [2 * x(1); 1; 2 * x(2); -1];
    
function hm = hessian(x, mu, scale)
    hm = [2 * scale + 2 * mu(1); -2 * scale + 2 * mu(1)];
        