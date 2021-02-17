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
    
    
    elseif strcmp(casefile, '418-1')
        mpc.trans  = ext2int(loadcase('case300'));
        mpc.dist = { ext2int(loadcase('case118'))
                     };

        mpc.connection_array = [ 1 2 10 1;

                           ];    
    elseif strcmp(casefile, '418-3')
        % 3 connections
        mpc.trans  = ext2int(loadcase('case300'));
        mpc.dist = { ext2int(loadcase('case118'))
                     };

        mpc.connection_array = [ 1 2 10 1;
                                 2 1 100 8;
                                 1 2 170 61;
                                 ];
                       
    elseif strcmp(casefile, '418-5')
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
                             
    elseif strcmp(casefile, '418-8')
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
    elseif strcmp(casefile, '418-10')
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


    %% 1654

      elseif strcmp(casefile, '1654-1')
        mpc.trans  = ext2int(loadcase('case1354pegase')); 
        mpc.dist = { ext2int(loadcase('case300'))
            };
        mpc.connection_array = [1 2 34 19
            
        ];
        
 
      elseif strcmp(casefile, '1654-3')
        mpc.trans  = ext2int(loadcase('case1354pegase')); 
        mpc.dist = { ext2int(loadcase('case300'))
            };
        mpc.connection_array = [1 2 34 19;
                                1 2 610 69;
                                1 2 744 120
            
        ];       
    
 
      elseif strcmp(casefile, '1654-5')
        mpc.trans  = ext2int(loadcase('case1354pegase')); 
        mpc.dist = { ext2int(loadcase('case300'))
            };
        mpc.connection_array = [1 2 34 19;
                                1 2 610 69;
                                1 2 744 120;
                                1 2 1310 150;
                                1 2 360 215
            
        ];      
    
      elseif strcmp(casefile, '1654-8')
        mpc.trans  = ext2int(loadcase('case1354pegase')); 
        mpc.dist = { ext2int(loadcase('case300'))
            };
        mpc.connection_array = [1 2 34 19;
                                1 2 610 69;
                                1 2 744 120;
                                1 2 1310 150;
                                1 2 360 215;
                                1 2 87 255;
                                1 2 499 260;
                                1 2 1016 192
         ];      
               
      elseif strcmp(casefile, '1654-10')
        mpc.trans  = ext2int(loadcase('case1354pegase')); 
        mpc.dist = { ext2int(loadcase('case300'))
            };
        mpc.connection_array = [1 2 34 19;
                                1 2 610 69;
                                1 2 744 120;
                                1 2 1310 150;
                                1 2 360 215;
                                1 2 87 255;
                                1 2 499 260;
                                1 2 1016 192;
                                1 2 1234 296;
                                1 2 920 131
         ];      

     elseif strcmp(casefile, '1654-12')
        mpc.trans  = ext2int(loadcase('case1354pegase')); 
        mpc.dist = { ext2int(loadcase('case300'))
            };
        mpc.connection_array = [1 2 34 19;
                                1 2 610 69;
                                1 2 744 120;
                                1 2 1310 150;
                                1 2 360 215;
                                1 2 87 255;
                                1 2 499 260;
                                1 2 1016 192;
                                1 2 1234 296;
                                1 2 920 131;
                                1 2 233 199;
                                1 2 421 156
                                
         ];      
     
      elseif strcmp(casefile, '1654-16')
        mpc.trans  = ext2int(loadcase('case1354pegase')); 
        mpc.dist = { ext2int(loadcase('case300'))
            };
        mpc.connection_array = [1 2 34 19;
                                1 2 610 69;
                                1 2 744 120;
                                1 2 1310 150;
                                1 2 360 215;
                                1 2 87 255;
                                1 2 499 260;
                                1 2 1016 192;
                                1 2 1234 296;
                                1 2 920 131;
                                1 2 233 199;
                                1 2 421 156;
                                1 2 986 88;
                                1 2 1086 222;
                                1 2 387 267;
                                1 2 551 8;
         ];      

    elseif strcmp(casefile, '1654-20')
        mpc.trans  = ext2int(loadcase('case1354pegase')); 
        mpc.dist = { ext2int(loadcase('case300'))
            };
        mpc.connection_array = [1 2 34 19;
                                1 2 610 69;
                                1 2 744 120;
                                1 2 1310 150;
                                1 2 360 215;
                                1 2 87 255;
                                1 2 499 260;
                                1 2 1016 192;
                                1 2 1234 296;
                                1 2 920 131;
                                
                                1 2 233 199;
                                1 2 421 156;
                                1 2 986 88;
                                1 2 1086 222;
                                1 2 387 267;
                                1 2 551 8;                                
                                1 2 152 10;
                                1 2 150 55;
                                1 2 715 63;
                                1 2 1177 251;
                               
                                
         ];
     
      elseif strcmp(casefile, '1654-25')
        mpc.trans  = ext2int(loadcase('case1354pegase')); 
        mpc.dist = { ext2int(loadcase('case300'))
            };
        mpc.connection_array = [1 2 34 19;
                                1 2 610 69;
                                1 2 744 120;
                                1 2 1310 150;
                                1 2 360 215;
                                1 2 87 255;
                                1 2 499 260;
                                1 2 1016 192;
                                1 2 1234 296;
                                1 2 920 131;
                                
                                1 2 233 199;
                                1 2 421 156;
                                1 2 986 88;
                                1 2 1086 222;
                                1 2 387 267;
                                1 2 551 8;                                
                                1 2 152 10;
                                1 2 150 55;
                                1 2 715 63;
                                1 2 1177 251;
                                
                                1 2 270 103;
                                1 2 323 169;
                                1 2 444 177;
                                1 2 1191 250;
                                1 2 1274 262
                                
                                
         ];      
     
     
    elseif strcmp(casefile, '1654-30')
        mpc.trans  = ext2int(loadcase('case1354pegase')); 
        mpc.dist = { ext2int(loadcase('case300'))
            };
        mpc.connection_array = [1 2 34 19;
                                1 2 610 69;
                                1 2 744 120;
                                1 2 1310 150;
                                1 2 360 215;
                                1 2 87 255;
                                1 2 499 260;
                                1 2 1016 192;
                                1 2 1234 296;
                                1 2 920 131;
                                
                                1 2 233 199;
                                1 2 421 156;
                                1 2 986 88;
                                1 2 1086 222;
                                1 2 387 267;
                                1 2 551 8;                                
                                1 2 152 10;
                                1 2 150 55;
                                1 2 715 63;
                                1 2 1177 251;
                                
                                1 2 270 103;
                                1 2 323 169;
                                1 2 444 177;
                                1 2 1191 250;
                                1 2 1274 262;                                
                                1 2 106 77;
                                1 2 627 164;
                                1 2 822 220;
                                1 2 1254 248;
                                1 2 1335 258
         ];  
     
     %%  2X1354 
    elseif strcmp(casefile, '2708-1') 
        mpc.trans  = ext2int(loadcase('case1354pegase'));
        mpc.dist = { ext2int(loadcase('case1354pegase'))
                    };
        % 
        
        mpc.connection_array = [1 2 21 21;

                           ];
    
    elseif strcmp(casefile, '2708-5') 
        mpc.trans  = ext2int(loadcase('case1354pegase'));
        mpc.dist = { ext2int(loadcase('case1354pegase'))
                    };
        % 
        
        mpc.connection_array = [1 2 21 21;
                            1 2 57 51;
                            1 2 135 79;
                            1 2 654 101;
                            1 2 1089 114;
                           ];
                       
    elseif strcmp(casefile, '2708-10') 
        mpc.trans  = ext2int(loadcase('case1354pegase'));
        mpc.dist = { ext2int(loadcase('case1354pegase'))
                    };
        % 
        
        mpc.connection_array = [1 2 21 21;
                            1 2 57 51;
                            1 2 135 79;
                            1 2 654 101;
                            1 2 1089 114;
                            
                            1 2 104 191;
                            1 2 255 278;
                            1 2 286 793;
                            1 2 702 1060;
                            1 2 844 1277;
                           ];
                           
     elseif strcmp(casefile, '2708-15') 
        mpc.trans  = ext2int(loadcase('case1354pegase'));
        mpc.dist = { ext2int(loadcase('case1354pegase'))
                    };
        % 
        
        mpc.connection_array = [1 2 21 21;
                            1 2 57 51;
                            1 2 135 79;
                            1 2 654 101;
                            1 2 1089 114;
                            
                            1 2 104 191;
                            1 2 255 278;
                            1 2 286 793;
                            1 2 702 1060;
                            1 2 844 1277;
                            
                            1 2 355 1026;
                            1 2 422 1092;
                            1 2 484 1140;
                            1 2 617 1240;
                            1 2 744 1328
                       ];                   

     elseif strcmp(casefile, '2708-20') 
        mpc.trans  = ext2int(loadcase('case1354pegase'));
        mpc.dist = { ext2int(loadcase('case1354pegase'))
                    };
        % 
        
        mpc.connection_array = [1 2 21 21;
                            1 2 57 51;
                            1 2 135 79;
                            1 2 654 101;
                            1 2 1089 114;
                            
                            1 2 104 191;
                            1 2 255 278;
                            1 2 286 793;
                            1 2 702 1060;
                            1 2 844 1277;
                            
                            1 2 355 1026;
                            1 2 422 1092;
                            1 2 484 1140;
                            1 2 617 1240;
                            1 2 744 1328;
                            
                            1 2 193 744;
                            1 2 551 822;
                            1 2 918 863;
                            1 2 1023 986;
                            1 2 1191 1000;
                       ];
                   
     elseif strcmp(casefile, '2708-30') 
        mpc.trans  = ext2int(loadcase('case1354pegase'));
        mpc.dist = { ext2int(loadcase('case1354pegase'))
                    };
        % 
        
        mpc.connection_array = [1 2 21 21;
                            1 2 57 51;
                            1 2 135 79;
                            1 2 654 101;
                            1 2 1089 114;
                            
                            1 2 104 191;
                            1 2 255 278;
                            1 2 286 793;
                            1 2 702 1060;
                            1 2 844 1277;
                            
                            1 2 355 1026;
                            1 2 422 1092;
                            1 2 484 1140;
                            1 2 617 1240;
                            1 2 744 1328;
                            
                            1 2 193 744;
                            1 2 551 822;
                            1 2 918 863;
                            1 2 1023 986;
                            1 2 1191 1000;
                            
                            1 2 375 356;
                            1 2 806 419;
                            1 2 987 480;
                            1 2 1240 551;
                            1 2 1306 598;
                            
                            1 2 320 383;
                            1 2 749 498;
                            1 2 811 624;
                            1 2 971 918;
                            1 2 1335 1181   
                       ];            
    
                 

%  3X1354
    elseif strcmp(casefile, '4062-1')

        mpc.trans  = ext2int(loadcase('case1354pegase'));
        mpc.dist = { ext2int(loadcase('case1354pegase'))
                     ext2int(loadcase('case1354pegase'))
                    };
        % 
        mpc.connection_array = [1 2 17 46;
                                1 3 111  271
                                ];
    elseif strcmp(casefile, 'test') 

        mpc.trans  = ext2int(loadcase('case1354pegase'));
        mpc.dist = { ext2int(loadcase('case1354pegase'))
                     ext2int(loadcase('case1354pegase'))
                    };
    % 

    mpc.connection_array = [
                            % reigion 1 - region 2
                            1 2 21 21;
                            1 2 57 51;
                            1 2 135 79;
                            1 2 654 101;
                            1 2 1089 114;
                            
                            1 2 104 191;
                            1 2 255 278;
                            1 2 286 793;
                            1 2 702 1060;
                            1 2 844 1277;
                            
                            1 2 355 1026;
                            1 2 422 1092;
                            1 2 484 1140;
                            1 2 617 1240;
                            1 2 744 1328;
                            
                            1 2 193 744;
                            1 2 551 822;
                            1 2 918 863;
                            1 2 1023 986;
                            1 2 1191 1000;
                            
                            1 2 375 356;
                            1 2 806 419;
                            1 2 987 480;
                            1 2 1240 551;
                            1 2 1306 598;
                            
                            1 2 320 383;
                            1 2 749 498;
                            1 2 811 624;
                            1 2 971 918;
                            1 2 1335 1181;
                            
                            % region 1 - region 3
                            %1 3 111  271
                            1 3 81 21;
                            1 3 154 51;
                            1 3 244 79;
                            1 3 271 101;
                            1 3 387 114;
                            
                            1 3 465 191;
                            1 3 510 278;
                            1 3 598 793;
                            1 3 676 1060;
                            1 3 715 1277;
                            
                            1 3 822 1026;
                            1 3 1000 1092;
                            1 3 1043 1140;
                            1 3 1121 1240;
                            1 3 1219 1328;
                            
                            1 3 1256 744;
                            1 3 1274 822;
                            1 3 1303 863;
                            1 3 1327 986;
                            1 3 1342 1000;
                            
                            1 3 861 356;
                            1 3 873 419;
                            1 3 895 480;
                            1 3 924 551;
                            1 3 993 598;
                            
                            1 3 406 383;
                            1 3 432 498;
                            1 3 136 624;
                            1 3 152 918;
                            1 3 210 1181
                            
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