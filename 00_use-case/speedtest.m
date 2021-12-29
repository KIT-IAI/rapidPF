t=zeros(100,1);
for i = 1:20
[xsol, xsol_stacked,logg] = solve_rapidPF_aladin(problem, mpc_split, option, names);
t(i) = logg.computing_time;
end
t0 = sum(t(11:end))/10
% %%
% opt = mpoption;

% g1 = obj.HQP*dy + obj.gQP
% g2 = - obj.AQP'*obj.KQP*(obj.bQP+obj.AQP*dy)
% 
% (obj.HQP - obj.AQP'*obj.KQP*obj.AQP) x = obj.AQP'*obj.KQP*obj.bQP - obj.gQP
% 
% ddy = (obj.HQP - obj.AQP'*obj.KQP*obj.AQP)\(obj.AQP'*obj.KQP*obj.bQP - obj.gQP) ;