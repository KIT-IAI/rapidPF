%     % assumption: least-square problem, i.e. without constraints
%     cost = @(x)build_cost(x);
%     grad = @(x)build_grad(x);
%     % unconstrained problem and Hessian is computed by hand
%     Hess = @(x, mu, scale)[2 * scale  , 0 , 0, -2  * scale];
%     lbx  = [-5;-5];
%     ubx  = [5;5];
%     x0   = [15;-3];
%     [xopt, multiplier] = worhp_interface(cost,grad,Hess,x0',lbx',ubx');
%     
% function fun = build_cost(x)
%     fun = (x(1)*x(1) - x(2)*x(2));
% end
% 
% function grad = build_grad(x)
%     grad = [2 * x(1); -2 * x(2)];
% end
options = optimoptions('fminunc','Algorithm','trust-region',...
'SpecifyObjectiveGradient',true,'HessianFcn','objective','Display','iter');

f = @(x)(1*(x(2)-x(1)^2)^2+(1-x(1))^2);
dfdx = @(x)[4*x(1)^3-4*x(1)*x(2) + 2*x(1)-2; 2*(x(2)-x(1)^2)];
H = @(x)[12*x(1)^2 - 4*x(2)+2, -4*x(1);-4*x(1), -2];
cost = @(x)build_cost_function(x,f(x),dfdx(x),H(x));
x0 = [5,5];
Nx = 2;
[xopt, fval, flag, ~, multiplier]  = fminunc(cost,x0,options);
[Hess.row,Hess.col,Hess.pos] = build_Hess_indx_worhp(H,Nx);
Hess.Func = H;
lbx = [-2,-2];
ubx = [2,2];
[xFinal,lambdaFinal]=worhp_interface(f,dfdx,Hess,x0,lbx,ubx);

function [fun, grad, Hessian] = build_cost_function(x, f, dfdx, H)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % the code assumes that Sigma is symmetric and positive definite!!!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fun = f;
    if nargout > 1
        grad = dfdx;
        if nargout > 2
            Hessian = H;
        end
    end
end

function [Hrow, Hcol, Hpos] = build_Hess_indx_worhp(H, Nx)
    nr = 3;
    S  = zeros(Nx,Nx);
    for i=1:nr
        S = S + full(H(rand(Nx,1)) ~=0);
    end
    % get sparsity
    S = S ~=0;
    % convert everything to vectors for WORHP
    [row, col] = find(S);
    position_number = find(S);
    
    diag = find(row == col);
    low_triangle = find(row>col);
    Hrow = [row(low_triangle);row(diag)]';
    Hcol = [col(low_triangle);col(diag)]';
    Hpos = [position_number(low_triangle); position_number(diag)];
end