function mpc = split_and_makeYbus(mpc, names)
% split_and_makeYbus
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

    NAME_FOR_REGION_FIELD = names.regions.global;
    NAME_FOR_SPLIT_CASE_FILE = names.split;
    
    N_regions = numel(mpc.(NAME_FOR_REGION_FIELD));
    [Y, mpc_cell] = deal(cell(N_regions, 1));
    for N = 1:N_regions
        mpc_cell{N} = split_case_file(mpc, N, names);
        Y{N} = makeYbus(ext2int(mpc_cell{N}));
    end
    mpc.Y = Y;
    mpc.(NAME_FOR_SPLIT_CASE_FILE) = mpc_cell;
end

