% return the number of branches in casefile
function N = get_number_of_branches(mpc)
    N = size(mpc.branch, 1);
    % check 1:N numbering
%     if sum(1:N) ~= sum(mpc.branch(:,1))
%         error('This code assumse 1:N numbering in buses. Please check.');
%     end
end