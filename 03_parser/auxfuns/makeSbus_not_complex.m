function [Pbus, Qbus, dSbus_dVm] = makeSbus_not_complex(baseMVA, bus, gen, mpopt, Vm, Sg)
% makeSbus_not_complex
%
%   `copy the declaration of the function in here (leave the ticks unchanged)`
%
%   _describe what the function does in the following line_
%
%   # Markdown formatting is supported
%   Equations are possible to, e.g $a^2 + b^2 = c^2$.
%   So are lists:
%   - item 1
%   - item 2
%   ```matlab
%   function y = square(x)
%       x^2
%   end
%   ```
%   See also: [run_case_file_splitter](run_case_file_splitter.md)
%   # This is originally part of matpower!!!
%   MAKESBUS   Builds the vector of complex bus power injections.
%   SBUS = MAKESBUS(BASEMVA, BUS, GEN)
%   SBUS = MAKESBUS(BASEMVA, BUS, GEN, MPOPT, VM)
%   SBUS = MAKESBUS(BASEMVA, BUS, GEN, MPOPT, VM, SG)
%   returns the vector of complex bus power injections, that is, generation
%   minus load. Power is expressed in per unit. If the MPOPT and VM arguments
%   are present it evaluates any ZIP loads based on the provided voltage
%   magnitude vector. If VM is empty, it assumes nominal voltage. If SG is
%   provided, it is a complex ng x 1 vector of generator power injections in
%   p.u., and overrides the PG and QG columns in GEN, using GEN only for
%   connectivity information.
%
%   [SBUS, DSBUS_DVM] = MAKESBUS(BASEMVA, BUS, GEN, MPOPT, VM)
%   With two output arguments, it computes the partial derivative of the
%   bus injections with respect to voltage magnitude, leaving the first
%   return value SBUS empty. If VM is empty, it assumes no voltage dependence
%   and returns a sparse zero matrix.
%
%   See also MAKEYBUS.

%   MATPOWER
%   Copyright (c) 1996-2016, Power Systems Engineering Research Center (PSERC)
%   by Ray Zimmerman, PSERC Cornell
%
%   This file is part of MATPOWER.
%   Covered by the 3-clause BSD License (see LICENSE file for details).
%   See https://matpower.org for more info.

%% define named indices into bus, gen matrices
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;

%% default inputs
if nargin < 5
    Vm = [];
    if nargin < 4
        mpopt = [];
    end
end
nb = size(bus, 1);

%% get load parameters
Sd = makeSdzip(baseMVA, bus, mpopt);

if nargout == 3
    Pbus = [];
    Qbus = [];
    if isempty(Vm)
        dSbus_dVm = sparse(nb, nb);
    else
        dSbus_dVm = -(spdiags(Sd.i + 2 * Vm .* Sd.z, 0, nb, nb));
    end
else
    %% compute per-bus generation in p.u.
    on = find(gen(:, GEN_STATUS) > 0);      %% which generators are on?
    gbus = gen(on, GEN_BUS);                %% what buses are they at?
    ngon = size(on, 1);
    Cg = sparse(gbus, (1:ngon)', 1, nb, ngon);  %% connection matrix
                                                %% element i, j is 1 if
                                                %% gen on(j) at bus i is ON
    if nargin > 5 && ~isempty(Sg)
%         Sbusg = Cg * Sg(on);
        Pbusg = Cg * real(Sg(on));
        Qbusg = Cg * imag(Sg(on));
    else
%         Sbusg = Cg * (gen(on, PG) + 1j * gen(on, QG)) / baseMVA;
        Pbusg = Cg * gen(on, PG) / baseMVA;
        Qbusg = Cg * gen(on, QG) / baseMVA;
    end

    %% compute per-bus loads in p.u.
    if isempty(Vm)
        Vm = ones(nb, 1);
    end
%     Sbusd = Sd.p + Sd.i .* Vm + Sd.z .* Vm.^2;
    
    Pbusd = real(Sd.p) + real(Sd.i) .* Vm + real(Sd.z) .* Vm.^2;
    Qbusd = imag(Sd.p) + imag(Sd.i) .* Vm + imag(Sd.z) .* Vm.^2;

    %% form net complex bus power injection vector
    %% (power injected by generators - power injected by loads)
%     Sbus = Sbusg - Sbusd;
    Pbus = Pbusg - Pbusd;
    Qbus = Qbusg - Qbusd;
    
end
