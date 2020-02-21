clear all;
close all;
clc;

mpc = loadcase('case1354pegase');
res = runpf(mpc);

Nline = 1958 % for case1354pegase
Nline = 1959 % for case1354pegase

% Nline = 36; % for case118


line_data = mpc.branch(Nline,:);
bus_from = find(mpc.bus(:,1) == line_data(1));
bus_to = find(mpc.bus(:,1) == line_data(2));

r = line_data(3);
x = line_data(4);
y = 1 / (r + 1i*x);
b = line_data(5);
ratio = line_data(9);
angle = line_data(10);
t = ratio*exp(1i*angle*pi/180);

Y = [ 1/ratio^2 * (y + 1i*b/2), -y/t; -y/t, y + 1i*b/2 ];
e_from = res.bus(bus_from,8)*exp(1i*res.bus(bus_from,9)*pi/180);
e_to = res.bus(bus_to,8)*exp(1i*res.bus(bus_to,9)*pi/180);
e = [e_from; e_to];

s = e .* conj(Y*e) * mpc.baseMVA

s_res = [   res.branch(Nline,14) + 1i*res.branch(Nline,15);
            res.branch(Nline,16) + 1i*res.branch(Nline,17)
        ]
    
norm(s - s_res)





