function [vang, vmag, pnet, qnet] = create_state(postfix, N)
    vang = sym(strcat('Va_', postfix, '_'), [N 1], 'real');
    vmag = sym(strcat('Vm_', postfix, '_'), [N 1], 'real');
    pnet = sym(strcat('P_', postfix, '_'), [N 1], 'real');
    qnet = sym(strcat('Q_', postfix, '_'), [N 1], 'real');
end