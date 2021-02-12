function mpc=mpc_data(casefile)
    mpc.fields_to_merge = {'bus', 'gen', 'branch'};
    if strcmp(casefile, '53-I')
    % small mpc 14+30+9
        mpc.trans  = loadcase('case14');
        mpc.dist = { loadcase('case30')
                     loadcase('case9')  };

        mpc.connection_array = [2 1 1 2;
                            2 3 2 3; 
                            2 3 13 1;
                            ];   
    elseif strcmp(casefile, '53-II')
    % small mpc 14+30+9
        mpc.trans  = loadcase('case14');
        mpc.dist = { loadcase('case30')
                     loadcase('case9')  };

        mpc.connection_array = [
                            % region 1 - region 2
                            1 2 2 1;
                            1 2 3 22;
                            % region 1 - region 3
                            1 3 6 2;
                            1 3 8 1;
                            % region 2 - region 3
                            2 3 13 3;
                            ];   

    elseif strcmp(casefile, '118X3')
    % 3x118
        mpc.trans  = loadcase('case118');
        mpc.dist = { loadcase('case118')
                     loadcase('case118')  
                    };
        % 
        mpc.connection_array = [2 1 1 8;
        %                     1 2 6 13;
        %                     1 3 3 2;
                           2 3 10 100; 
                           2 3 32 70;
                           ];

% infeasible example
    elseif strcmp(casefile, '300X3(infesible)')

        mpc.trans  = ext2int(loadcase('case300'));
        mpc.dist = { ext2int(loadcase('case300'))
                     ext2int(loadcase('case300'))};

        mpc.connection_array = [1 2 10 10
                            2 3 8 10
                            1 3 10  8
                           ];  
    
    
    elseif strcmp(casefile, '418-I')
        mpc.trans  = ext2int(loadcase('case300'));
        mpc.dist = { ext2int(loadcase('case118'))
                     };

        mpc.connection_array = [ 1 2 10 1;

                           ];    
    elseif strcmp(casefile, '418-II')
        % 3 connections
        mpc.trans  = ext2int(loadcase('case300'));
        mpc.dist = { ext2int(loadcase('case118'))
                     };

        mpc.connection_array = [ 1 2 10 1;
                                 2 1 100 8;
                                 1 2 170 61;
                                 ];
                       
    elseif strcmp(casefile, '418-III')
        % 5 connections
        mpc.trans  = ext2int(loadcase('case300'));
        mpc.dist = { ext2int(loadcase('case118'))
                     };

        mpc.connection_array = [ 1 2 10 1;
                                 2 1 100 8;
                                 1 2 170 61;
                                 1 2 120 32;
                                 1 2 260 80                              
                                 ];     
                             
    elseif strcmp(casefile, '418-IV')
        % 8 connections
        mpc.trans  = ext2int(loadcase('case300'));
        mpc.dist = { ext2int(loadcase('case118'))
                     };

        mpc.connection_array = [ 1 2 10 1;
                                 2 1 100 8;
                                 1 2 170 61;
                                 1 2 120 32;
                                 1 2 260 80;
                                 1 2 132 110;
                                 1 2 250 62;
                                 1 2 256 19;
                                 ];
    elseif strcmp(casefile, '418-V')
        mpc.trans  = ext2int(loadcase('case300'));
        mpc.dist = { ext2int(loadcase('case118'))
                     };
        % 5 connections
        mpc.connection_array = [ 1 2 10 1;
                                 2 1 100 8;
                                 1 2 170 61;
                                 1 2 120 32;
                                 1 2 260 80;
                                 1 2 132 110;
                                 1 2 250 62;
                                 1 2 256 19;
                                 1 2 206 46;
                                 1 2 156 15
                                 ];                      
    elseif strcmp(casefile, '118X7')
    %  7x118
        mpc.trans  = loadcase('case118');
        mpc.dist = {loadcase('case118')
                    loadcase('case118')  
                    loadcase('case118')
                    loadcase('case118')
                    loadcase('case118')
                    loadcase('case118')
                    };

        mpc.connection_array = [2 1 1 8;
                            2 3 10 100; 
                            2 3 32 70;
                            1 4 19 74;
                            4 5 113 92
                            5 6 116 72;
                            1 7 10  32
                           ];
    elseif strcmp(casefile, '118X8')
        %  8x118
        mpc.trans  = loadcase('case118');
        mpc.dist = {loadcase('case118')
                    loadcase('case118')  
                    loadcase('case118')
                    loadcase('case118')
                    loadcase('case118')
                    loadcase('case118')
                    loadcase('case118')
                    };

        mpc.connection_array = [2 1 1 8;
                            2 3 10 100; 
                            2 3 32 70;
                            1 4 19 74;
                            4 5 113 92
                            5 6 116 72;
                            1 7 10  32
                            1 8 32  100
                           ];
      elseif strcmp(casefile, '118X10')

    %  10x118
        mpc.trans  = loadcase('case118');
        mpc.dist = {loadcase('case118')
                    loadcase('case118')  
                    loadcase('case118')
                    loadcase('case118')
                    loadcase('case118')
                    loadcase('case118')
                    loadcase('case118')
                    loadcase('case118')
                    loadcase('case118')
                    };

        mpc.connection_array = [2 1 1 8;
                            2 3 10 100; 
                            2 3 32 70;
                            1 4 19 74;
                            4 5 113 92
                            5 6 116 72;
                            1 7 10  32
                            1 8 32  100
                            8 9 10 74;
                            7 9 70 113;
                            8 10 19 100;
                           ];


%%  2X1354
    elseif strcmp(casefile, '1354X2')
        mpc.trans  = ext2int(loadcase('case1354pegase'));
        mpc.dist = { ext2int(loadcase('case1354pegase'))

                    };
        % 
        mpc.connection_array = [1 2 17 17;

                           ];

%%  3X1354
    elseif strcmp(casefile, '1354X3')

        mpc.trans  = ext2int(loadcase('case1354pegase'));
        mpc.dist = { ext2int(loadcase('case1354pegase'))
                     ext2int(loadcase('case1354pegase'))
                    };
        % 
        mpc.connection_array = [1 2 17 46;
                                1 3 111  271
                                ];
    
    elseif strcmp(casefile, '1354X3+300X2')
    % 3X1354+2X300                  
        mpc.trans  = ext2int(loadcase('case1354pegase'));
        mpc.dist = { ext2int(loadcase('case1354pegase'))
                     ext2int(loadcase('case1354pegase'))
                     ext2int(loadcase('case300'))
                     ext2int(loadcase('case300'))
                    };

        mpc.connection_array = [1 2 17 46;
                                1 3 111  271;   
                                2 4  64  10;
                                2 5  837  8;
                           ];
    end
end