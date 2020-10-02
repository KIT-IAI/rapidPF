function [xFinal,lambdaFinal, muFinal]=worhp_interface(f,dfdx,g,Jac,Hess,x0,lbx,ubx)

Nx = numel(x0);
Hess_position = Hess.nonzero_pos;
Jac_position = Jac.nonzero_pos;

if isempty(g(x0))
    % unconstrained problem
    Ng   =  1;
    gl   =  0;
    gu   =  0;
    g    =  @(x)0;
else
    Ng  = numel(g(x0));
    gl  = zeros(1,Ng);
    gu  = zeros(1,Ng);
end


% Box constraints for X
wData.XL = lbx';
wData.XU = ubx';

% Define bounds for G
wData.GL = gl;
wData.GU = gu;

% Initial estimates for X and Lambda
wData.xInit = x0';
wData.lambdaInit = zeros(size(wData.XL)); 
% and for Mu
wData.muInit = zeros(size(wData.GL));%zeros(size(wData.GL));
% Initialise sparsity structure of derivates
% according to the WORHP user manual (Coordinate Storage format)
% full sparse

X_idx       =  1:Nx;
G_idx       =  1:Ng;
% DGrow       =  repmat(G_idx, 1, Nx);
% DGcol       =  repmat(X_idx, Ng, 1);
% DGcol       =  DGcol(:);

DGrow       =  Jac_position.row';
DGcol       =  Jac_position.col;

wData.DFrow =  int32(X_idx);
wData.DGrow =  int32(DGrow);%int32(ones(1,Nx));
wData.DGcol =  int32(DGcol');%int32(X_idx);
HMrow       = [Hess_position.triangle.row', X_idx];
HMcol       = [Hess_position.triangle.col', X_idx];
wData.HMrow =  int32(HMrow);
wData.HMcol =  int32(HMcol);
wData.param =  'worhp.xml';

% The callback functions.
wCallback.f           = @(x)f(x);%@objective;
wCallback.g           = @(x)g(x)';%@constraints;
wCallback.df          = @(x)dfdx(x)';%@gradient;
wCallback.dg          = @(x)build_Jac_vector(Jac.Func(x),Jac_position.idx);%@jacobian;
wCallback.hm          = @(x,mu,scale)build_Hess_vector(Hess.Func(x, mu, scale),Hess_position,Nx);
% wCallback.hm          = @(x, mu, scale)hessian(x, mu, scale, posCombined, Hess);%@hessian;
% Call the solver
tic
[xFinal,lambdaFinal,muFinal,solverstatus] = worhp(wData, wCallback);
toc
end

function Hess_vector = build_Hess_vector(Hess,nonzero_pos,Nx)
    % non-diag nonzeros element come first
    Hess_vec_triangle  =  Hess(nonzero_pos.triangle.idx)';
    % diag element, including zero element in sequence, comes second
    Hess_vec_diag      =  zeros(1,Nx);
    Hess_vec_diag(nonzero_pos.diag.iith) = Hess(nonzero_pos.diag.idx);
    Hess_vector    =  [Hess_vec_triangle, Hess_vec_diag];
end

function Jac_vector = build_Jac_vector(Jac, nonzero_pos)
%     Jac_vector = full(Jac(:))';
    Jac_vector = Jac(nonzero_pos);
end
