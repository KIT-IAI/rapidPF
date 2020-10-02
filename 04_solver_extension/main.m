% Hessian
H = @(x)[x(1) x(2); x(2) 0];

% evaluate for some random points
nr = 3;
S = zeros(2,2);
for i=1:nr
    S = S + full(H(rand(2,1)) ~=0);
end

% get sparsity
S = S ~=0;

% convert everything to vectors for WORHP
[ HMrow, HMcol ] = find(S);
posCombined   = find(S);

hess2vec(rand(2,1),posCombined,H)

function hVec = hess2vec(x, mu, scale,posCombined,Hess) 
    H = Hess(x,mu, scale);
    hVec = H(posCombined);
end