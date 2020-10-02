function hVec = hess2vec(x, mu, scale,posCombined,Hess) 
    H = Hess(x,mu, scale);
    hVec = H(posCombined);
end