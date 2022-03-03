[xsol,et] = solve_rapidPF_aladin_speedtest(problem, mpc_split, option, names);
et
Nconnections
% %%
% opt = mpoption;

% g1 = obj.HQP*dy + obj.gQP
% g2 = - obj.AQP'*obj.KQP*(obj.bQP+obj.AQP*dy)
% 
% (obj.HQP - obj.AQP'*obj.KQP*obj.AQP) x = obj.AQP'*obj.KQP*obj.bQP - obj.gQP
% 
% ddy = (obj.HQP - obj.AQP'*obj.KQP*obj.AQP)\(obj.AQP'*obj.KQP*obj.bQP - obj.gQP) ;
%%

    opt = mpoption;
    opt.verbose = 0;
    opt.out.all = 0;
    t_centr=zeros(10,1);
% % 
    for i = 1:10
       t0 = tic;
        [res, flag] = runpf(mpc_merge, opt);
        t_centr(i)= toc(t0);      
    end
t1 = sum(t_centr)/10


%%
