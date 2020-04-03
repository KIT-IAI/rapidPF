function tab = build_connection_table(connections, trafo_pars)
% build_connection_table
%
%   `tab = build_connection_table(connections, trafo_pars)`
%
%   _Generate a table that encodes connection among systems and their buses._
%
%   ## Inputs
%
%   Input | Type | Description 
%   :--- | :--- | :--- 
%   `connections` | `array` | Array of dimension $n_{\text{conn}} \times 4$ (see info below).
%   `trafo_pars` | `struct` or `cell` |  Parameters of connecting transformers
%
%   </br>
%   The four columns of the array `connections` encode which bus of which
%   system connects to which bus of another system. Let $c
%   \in \mathbb{R}^{1 \times 4}$ be a row of `connections`. Then, system
%   $c_1$ connects to system $c_2$, specifically bus $c_3$ of system
%   $c_1$ connects to bus $c_4$ of system $c_2$.
%
%   The transformer connecting both systems is specified in `trafo_pars`,
%   where each row entry of `connections` corresponds to the respective
%   entry in `trafo_pars`. If `trafo_pars` is but a `struct`, then the same
%   transformer is assumed to connect all systems, and a warning is
%   displayed.
%
%   
%   ## Outputs
%
%   Output | Type | Description
%   :--- | :--- | :---
%   `tab` | `table` | Table that encodes connection among systems and their buses
%
%   </br>
%
%   ## Example
%   The following example connects three systems (the second at bus 1 to the first at bus 2,
%   the second to the third twice, namely at buses 2 and 3, and 13 and 1), all by the same transformer.
%
%   ```matlab
%   connection_array = [2 1 1 2; 2 3 2 3; 2 3 13 1 ];
% 
%   trafo_params.r = 0;
%   trafo_params.x = 0.00623;
%   trafo_params.b = 0;
%   trafo_params.ratio = 0.985;
%   trafo_params.angle = 0;
% 
%   conn = build_connection_table(connection_array, trafo_params)
%   3x5 table
% 
%          from_sys    to_sys    from_bus    to_bus     trafo_pars 
%          ________    ______    ________    ______    ____________
% 
%     1       1          2           2         1       {1x1 struct}
%     2       2          3           2         3       {1x1 struct}
%     3       2          3          13         1       {1x1 struct}
%   ```
%   ## See also
%   </br>
    N = size(connections, 1);
    
    from_sys = connections(:, 1);
    to_sys = connections(:, 2);
    from_bus = connections(:, 3);
    to_bus = connections(:, 4);
    trafo_pars = check_trafo_params(trafo_pars, N);
    connections = [1:N]'; 
    tab = table(from_sys, to_sys, from_bus, to_bus, trafo_pars, 'RowNames', string(connections));
    tab = check_ordering(tab);
end

function pars = check_trafo_params(pars, N)
    if isstruct(pars)
        pars = repmat({pars}, N, 1);
        warning('Assuming the same transformer parameters for all connections. Please double-check.')
    else
        assert(numel(pars) == N, 'inconsistent number of transformer parameters.');
    end
end

function tab = check_ordering(tab)
    % check whether from_sys < to_sys holds everywhere
    % if not, then swap system and bus entries
    inds = ~(tab.from_sys < tab.to_sys);
    if sum(inds) ~= 0
        warning('fixing inconsistent connection labelling (from_sys < to_sys not satisfied everywhere).');
        
        f = tab.from_sys(inds);
        t = tab.to_sys(inds);
        tab.from_sys(inds) = t;
        tab.to_sys(inds) = f;
        
        f = tab.from_bus(inds);
        t = tab.to_bus(inds);
        tab.from_bus(inds) = t;
        tab.to_bus(inds) = f;
    end
end