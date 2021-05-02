function mpc = mpc_merge_split
%MPC_MERGE_SPLIT

%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin	lam_P	lam_Q	mu_Vmax	mu_Vmin
mpc.bus = [
	1	2	0	0	0	0	1	1.08492247	2.09607558	230	1	1.1	0.9	29.8339	0.0000	0.0000	0.0000;
	2	1	300	98.61	0	0	1	1.07444025	-0.161333044	230	1	1.1	0.9	30.0757	0.0430	0.0000	0.0000;
	3	2	300	98.61	0	0	1	1.08358895	0.513085573	230	1	1.1	0.9	30.0000	0.0000	0.0000	0.0000;
	4	3	400	131.47	0	0	1	1.08262907	0	230	1	1.1	0.9	30.0534	0.0000	0.0000	0.0000;
	5	2	0	0	0	0	1	1.08791679	3.25443171	230	1	1.1	0.9	29.7135	0.0000	0.0000	0.0000;
	6	2	0	0	0	0	1	1.0982527	0.992065913	230	1	1.1	0.9	29.8648	0.0000	0.0000	0.0000;
	7	1	300	98.61	0	0	1	1.08797688	-1.02594578	230	1	1.1	0.9	30.0812	0.0416	0.0000	0.0000;
	8	2	300	98.61	0	0	1	1.09699403	-0.29719505	230	1	1.1	0.9	30.0000	0.0000	0.0000	0.0000;
	9	2	400	131.47	0	0	1	1.09479564	-1.24884322	230	1	1.1	0.9	30.0995	0.0000	0.0000	0.0000;
	10	1	0	0	0	0	1	1.1	1.28086191	230	1	1.1	0.9	29.8337	-0.0108	320.3592	0.0000;
];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf	mu_Pmax	mu_Pmin	mu_Qmax	mu_Qmin
mpc.gen = [
	1	40	3.43105871	30	-30	1.08492247	100	1	40	0	0	0	0	0	0	0	0	0	0	0	0	15.8339	0.0000	0.0000	0.0000;
	1	170	35.5624823	127.5	-127.5	1.08492247	100	1	170	0	0	0	0	0	0	0	0	0	0	0	0	14.8339	0.0000	0.0000	0.0000;
	3	470.177037	176.3076	390	-390	1.08358895	100	1	520	0	0	0	0	0	0	0	0	0	0	0	0	0.0000	0.0000	0.0000	0.0000;
	4	4.27028697e-08	148.49222	150	-150	1.08262907	100	1	200	0	0	0	0	0	0	0	0	0	0	0	0	0.0000	9.9466	0.0000	0.0000;
	5	600	18.1841424	450	-450	1.08791679	100	1	600	0	0	0	0	0	0	0	0	0	0	0	0	19.7135	0.0000	0.0000	0.0000;
	6	40	1.75262358	30	-30	1.0982527	100	1	40	0	0	0	0	0	0	0	0	0	0	0	0	15.8648	0.0000	0.0000	0.0000;
	6	170	3.10464255	127.5	-127.5	1.0982527	100	1	170	0	0	0	0	0	0	0	0	0	0	0	0	14.8648	0.0000	0.0000	0.0000;
	8	515.674602	176.684679	390	-390	1.09699403	100	1	520	0	0	0	0	0	0	0	0	0	0	0	0	0.0000	0.0000	0.0000	0.0000;
	9	4.29015966e-08	138.064008	150	-150	1.09479564	100	1	200	0	0	0	0	0	0	0	0	0	0	0	0	0.0000	9.9005	0.0000	0.0000;
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax	Pf	Qf	Pt	Qt	mu_Sf	mu_St	mu_angmin	mu_angmax
mpc.branch = [
	1	2	0.00281	0.0281	0.00712	0	0	0	0	0	1	-360	360	166.1071	26.6607	-165.4309	-20.7287	0.0000	0.0000	0.0000	0.0000;
	1	4	0.00304	0.0304	0.00658	0	0	0	0	0	1	-360	360	140.9835	-3.7157	-140.4698	8.0791	0.0000	0.0000	0.0000	0.0000;
	1	5	0.00064	0.0064	0.03126	0	0	0	0	0	1	-360	360	-373.7856	-11.4518	374.5457	15.3639	0.0000	0.0000	0.0000	0.0000;
	2	3	0.00108	0.0108	0.01852	0	0	0	0	0	1	-360	360	-134.5691	-77.8813	134.7937	77.9712	0.0000	0.0000	0.0000	0.0000;
	3	4	0.00297	0.0297	0.00674	0	0	0	0	0	1	-360	360	35.3834	-0.2736	-35.3517	-0.2004	0.0000	0.0000	0.0000	0.0000;
	4	5	0.00297	0.0297	0.00674	0	0	0	0	0	1	-360	360	-224.1785	9.1435	225.4543	2.8203	0.0000	0.0000	0.0000	0.0000;
	6	7	0.00281	0.0281	0.00712	0	0	0	0	0	1	-360	360	152.4912	27.1204	-151.9318	-22.3770	0.0000	0.0000	0.0000	0.0000;
	6	9	0.00304	0.0304	0.00658	0	0	0	0	0	1	-360	360	154.6558	-0.3485	-154.0530	5.5857	0.0000	0.0000	0.0000	0.0000;
	6	10	0.00064	0.0064	0.03126	0	0	0	0	0	1	-360	360	-97.1470	-21.9147	97.1992	18.6603	0.0000	0.0000	0.0000	0.0000;
	7	8	0.00108	0.0108	0.01852	0	0	0	0	0	1	-360	360	-148.0682	-76.2330	148.3198	76.5380	0.0000	0.0000	0.0000	0.0000;
	8	9	0.00297	0.0297	0.00674	0	0	0	0	0	1	-360	360	67.3548	1.5367	-67.2428	-1.2255	0.0000	0.0000	0.0000	0.0000;
	9	10	0.00297	0.0297	0.00674	0	0	0	0	0	1	-360	360	-178.7043	2.2338	179.4958	4.8696	0.0000	0.0000	0.0000	0.0000;
	1	10	0	0.00623	0	0	0	0	0.985	0	1	0	0	276.6950	27.5002	-276.6950	-23.5298	0.0000	0.0000	0.0000	0.0000;
];

%%-----  OPF Data  -----%%
%% generator cost data
%	1	startup	shutdown	n	x1	y1	...	xn	yn
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
	2	0	0	2	14	0;
	2	0	0	2	15	0;
	2	0	0	2	30	0;
	2	0	0	2	40	0;
	2	0	0	2	10	0;
	2	0	0	2	14	0;
	2	0	0	2	15	0;
	2	0	0	2	30	0;
	2	0	0	2	40	0;
];
