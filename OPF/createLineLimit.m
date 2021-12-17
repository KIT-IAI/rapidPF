function h = createLineLimit(x,Fmax,Yf,Yt,Cf,Ct,N)
    Vang = x(1:N);
    Vmag = x((N+1):2*N);
    V  = Vmag.*exp(j*Vang);
    V_conj = Vmag.*exp(-j*Vang);
    Sf = (Cf*V).*conj(Yf)*V_conj;
    St = (Ct*V).*conj(Yt)*V_conj;
    h  = vertcat(Sf,St)-vertcat(Fmax,Fmax);
end