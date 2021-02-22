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
    
                 

%%  3X1354
    elseif strcmp(casefile, '4062-1')

        mpc.trans  = ext2int(loadcase('case1354pegase'));
        mpc.dist = { ext2int(loadcase('case1354pegase'))
                     ext2int(loadcase('case1354pegase'))
                    };
        % 
        mpc.connection_array = [1 2 17 46;
                                1 3 111  271
                                ];
                            
    elseif strcmp(casefile, '4062-30')

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

                            
        elseif strcmp(casefile, '4062-final')

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

    elseif strcmp(casefile, 'test') 

        mpc.trans  = ext2int(loadcase('case1354pegase'));
        mpc.dist = { ext2int(loadcase('case1354pegase'))
                     ext2int(loadcase('case1354pegase'))
                     ext2int(loadcase('case300'))
                      ext2int(loadcase('case300'))
                    };

    % 
%     mpc.connection_array = [
%                             % reigion 1 - region 2
%                             1 2 21 21;
%                             1 2 57 51;
%                             1 2 135 79;
%                             1 2 654 101;
%                             1 2 1089 114;
%                             
%                             1 2 104 191;
%                             1 2 255 278;
%                             1 2 286 793;
%                             1 2 702 1060;
%                             1 2 844 1277;
%                             
%                             1 2 355 1026;
%                             1 2 422 1092;
%                             1 2 484 1140;
%                             1 2 617 1240;
%                             1 2 744 1328;
%                             
%                             1 2 193 744;
%                             1 2 551 822;
%                             1 2 918 863;
%                             1 2 1023 986;
%                             1 2 1191 1000;
%                             
%                             1 2 375 356;
%                             1 2 806 419;
%                             1 2 987 480;
%                             1 2 1240 551;
%                             1 2 1306 598;
%                             
%                             1 2 320 383;
%                             1 2 749 498;
%                             1 2 811 624;
%                             1 2 971 918;
%                             1 2 1335 1181;
%                             
%                             1 2 79 136;
%                             1 2 154 154;
%                             1 2 233 244;
%                             1 2 270 323;
%                             1 2 405 406;
%                             
%                             1 2 444 750;
%                             1 2 468 895;
%                             1 2 502 945;
%                             1 2 518 1223;
%                             1 2 574 1304;
%                             
%                             % region 1 - region 3
%                             %1 3 111  271
%                             1 3 81 21;
%                             1 3 154 51;
%                             1 3 244 79;
%                             1 3 271 101;
%                             1 3 387 114;
%                             
%                             1 3 465 191;
%                             1 3 510 278;
%                             1 3 598 793;
%                             1 3 676 1060;
%                             1 3 715 1277;
%                             
%                             1 3 822 1026;
%                             1 3 1000 1092;
%                             1 3 1043 1140;
%                             1 3 1121 1240;
%                             1 3 1219 1328;
%                             
%                             1 3 1256 744;
%                             1 3 1274 822;
%                             1 3 1303 863;
%                             1 3 1327 986;
%                             1 3 1342 1000;
%                             
%                             1 3 861 356;
%                             1 3 873 419;
%                             1 3 895 480;
%                             1 3 924 551;
%                             1 3 993 598;
%                             
%                             1 3 406 383;
%                             1 3 432 498;
%                             1 3 136 624;
%                             1 3 152 918;
%                             1 3 210 1181;    
%                             % region 1 - region 4
% %                             
% %                             1 4 625 103;
% %                             1 4 676 169;
% %                             1 4 715 177;
% %                             1 4 782 250;
% %                             1 4 822 262;                                
% %                             1 4 1011 77;
% %                             1 4 1060 164;
% %                             1 4 1223 220;
% %                             1 4 1274 248;
% %                             1 4 1327 258;                         
% 
%                             % region 2 - region 4
%                             
%                             2 4 43 19;
%                             2 4 286 69;
%                             2 4 469 120;
%                             2 4 502 150;
%                             2 4 559 215;
%                             2 4 660 255;
%                             2 4 721 260;
%                             2 4 811 192;
%                             2 4 1016 296;
%                             2 4 1035 131;
% 
%                             2 4 1086 199;
%                             2 4 1121 156;
%                             2 4 1172 88;
%                             2 4 1256 222;
%                             2 4 1336 267;
%                             2 4 1344 8;                                
%                             2 4 255 10;
%                             2 4 586 55;
%                             2 4 627 63;
%                             2 4 931 251;
% 
% %                             
%                             1 4 625 103;
%                             1 4 676 169;
%                             1 4 715 177;
%                             1 4 782 250;
%                             1 4 822 262;                                
%                             1 4 1011 77;
%                             1 4 1060 164;
%                             1 4 1223 220;
%                             1 4 1274 248;
%                             1 4 1327 258;     
%                             
%                             % region 2 - region 5
%                             
%                             2 5 64 8;
%                             2 5 72 10;
%                             2 5 78 55;
%                             2 5 87 69;
%                             2 5 95 77;
%                             2 5 97 117;
%                             2 5 102 128;
%                             2 5 152 135;
%                             2 5 181 155;
%                             2 5 233 200
% 
%                             2 5 270 209;
%                             2 5 320 215;
%                             2 5 331 218;
%                             2 5 334 247;
%                             2 5 345 251;
%                             2 5 387 253;                                
%                             2 5 447 258;
%                             2 5 468 261;
%                             2 5 518 292;
%                             2 5 534 296;
%                             
%                             % region 2 - region 3
%                             
%                             2 3 106 233;
%                             2 3 205 320;
%                             2 3 353 367;
%                             2 3 367 434;
%                             2 3 434 510;
%                             
%                             2 3 688 688;
%                             2 3 782 732;
%                             2 3 837 750;
%                             2 3 993 1223;
%                             2 3 1196 1303;
%                             
%                             % region 4 - region 5
% 
% %                             5 4 104 103;
% %                             5 4 125 169;
% %                             5 4 131 177;
% %                             5 4 164 250;
% %                             5 4 169 262;                                
% %                             5 4 192 77;
% %                             5 4 221 164;
% %                             5 4 256 220;
% %                             5 4 265 248;
% %                             5 4 294 258                                 
%                        ]; 
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
                            
                            1 2 79 136;
                            1 2 154 154;
                            1 2 233 244;
                            1 2 270 323;
                            1 2 405 406;
                            
                            1 2 444 750;
                            1 2 468 895;
                            1 2 502 945;
                            1 2 518 1223;
                            1 2 574 1304;
                            
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
                            1 3 210 1181;    
                            % region 1 - region 4
%                             
%                             1 4 625 103;
%                             1 4 676 169;
%                             1 4 715 177;
%                             1 4 782 250;
%                             1 4 822 262;                                
%                             1 4 1011 77;
%                             1 4 1060 164;
%                             1 4 1223 220;
%                             1 4 1274 248;
%                             1 4 1327 258;                         

                            % region 2 - region 4
                            
                            2 4 43 19;
                            2 4 286 69;
                            2 4 469 120;
                            2 4 502 150;
                            2 4 559 215;
                            2 4 660 255;
                            2 4 721 260;
                            2 4 811 192;
                            2 4 1016 296;
                            2 4 1035 131;

                            2 4 1086 199;
                            2 4 1121 156;
                            2 4 1172 88;
                            2 4 1256 222;
                            2 4 1336 267;
                            2 4 1344 8;                                
                            2 4 255 10;
                            2 4 586 55;
                            2 4 627 63;
                            2 4 931 251;

%                             
                            1 4 625 103;
                            1 4 676 169;
                            1 4 715 177;
                            1 4 782 250;
                            1 4 822 262;                                
%                             1 4 1011 77;
%                             1 4 1060 164;
%                             1 4 1223 220;
%                             1 4 1274 248;
%                             1 4 1327 258;     
                            
                            % region 2 - region 5
                            
                            2 5 64 8;
                            2 5 72 10;
                            2 5 78 55;
                            2 5 87 69;
                            2 5 95 77;
                            2 5 97 117;
                            2 5 102 128;
                            2 5 152 135;
                            2 5 181 155;
                            2 5 233 200;

                            2 5 270 209;
                            2 5 320 215;
                            2 5 331 218;
                            2 5 334 247;
                            2 5 345 251;
                            2 5 387 253;                                
                            2 5 447 258;
                            2 5 468 261;
                            2 5 518 292;
                            2 5 534 296;
                            
                            % region 2 - region 3
                            
                            2 3 106 233;
                            2 3 205 320;
                            2 3 353 367;
                            2 3 367 434;
                            2 3 434 510;
                            
                            2 3 688 688;
                            2 3 782 732;
                            2 3 837 750;
                            2 3 993 1223;
                            2 3 1196 1303;
                            
                            % region 4 - region 5

                            5 3 104 931;
                            5 3 125 627;
                            5 3 131 586;
                            5 3 164 255;
                            5 3 169 1344;                                
%                             5 4 192 77;
%                             5 4 221 164;
%                             5 4 256 220;
%                             5 4 265 248;
%                             5 4 294 258                                 
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