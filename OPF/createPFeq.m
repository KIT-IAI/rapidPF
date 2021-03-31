function [ gP, gQ ] = createPFeq( x, Y, Ngens, genNodes, Pd, Qd )
    N       =   size(Y,1);

    G       =   real(Y);
    B       =   imag(Y);

    theta   =   x(1:N);
    V       =   x((N+1):(2*N));
    Pg      =   x((2*N+1):(2*N+Ngens));
    Qg      =   x((2*N+Ngens+1):(2*(N+Ngens)));

    gP = [];
    gQ = []; 
    for i=1:N
        sumP = 0;
        sumQ = 0;
        for j=1:N
            sumP = sumP+V(j)*(G(i,j)*cos(theta(i)-theta(j))+B(i,j)*sin(theta(i)-theta(j)));
            sumQ = sumQ+V(j)*(G(i,j)*sin(theta(i)-theta(j))-B(i,j)*cos(theta(i)-theta(j)));
        end
        gP = [gP;V(i)*sumP+Pd(i)];
        gQ = [gQ;V(i)*sumQ+Qd(i)];
    end
    gP(genNodes)  = gP(genNodes) - Pg; 
    gQ(genNodes)  = gQ(genNodes) - Qg; 
end

