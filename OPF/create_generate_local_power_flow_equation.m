function [ pf_p, pf_q ] = create_generate_local_power_flow_equation(x, Ybus,Ngen,Nnet,Ncopy, genNodes, Pd, Qd )
    Nbus    =   size(Ybus,1);
    Ncore
    if ~((Ngen+Nnet+Ncopy) == Nbus)
        error('bus number not correct')
    end
    G       =   real(Ybus);
    B       =   imag(Ybus);
    
    theta   =   x(1:N);
    V       =   x((N+1):(2*N));
    Pg      =   x((2*N+1):(2*N+Ngen));
    Qg      =   x((2*N+Ngen+1):(2*(N+Ngen)));

    pf_p = zeros(Nbus,1);
    pf_q = zeros(Nbus,1); 
    for i=1:Nbus
        % 
        sumP = 0;
        sumQ = 0;
        for j=1:N
            sumP = sumP+V(j)*(G(i,j)*cos(theta(i)-theta(j))+B(i,j)*sin(theta(i)-theta(j)));
            sumQ = sumQ+V(j)*(G(i,j)*sin(theta(i)-theta(j))-B(i,j)*cos(theta(i)-theta(j)));
        end
        pf_p = [pf_p;V(i)*sumP+Pd(i)];
        pf_q = [pf_q;V(i)*sumQ+Qd(i)];
    end
    pf_p(genNodes)  = pf_p(genNodes) - Pg; 
    pf_q(genNodes)  = pf_q(genNodes) - Qg; 
end