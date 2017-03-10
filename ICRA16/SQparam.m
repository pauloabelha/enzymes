%
% return SQ params (fixed and lower/upper bounds) according to the shape
%(e.g. 'handle' is a cylinder)
%
% flags for tapering and bending further define lambda fixed
%
% Where:   lambda - variables, which should be found:
%               lambda(1)-(3) - Scale (a1-a3)
%               lambda(4)-(5) - Shape (epsilon1 and 2)
%               lambda(6)-(8) - Euler angles (phi, theta, psi in ZYZ)
%               lambda(9)-(10) - z-axis Tapering params (K_x,K_y)
%               position is never returned as a fixed or bound parameter
function [lambda_fixed,lambda_lower_def,lambda_upper_def,lambda_default,part_type,tapering_out] = SQparam(shape,tapering_in,bending)
    tapering_out = tapering_in;
    part_type = 'default';
    lambda_fixed = [];
    lambda_lower_def = [0.01,0.01,0.01,0.01,0.01,0,0,0,-1,-1,0,0,-100,-100,-100];
    lambda_upper_def = [0.2,0.2,0.2,2,2,pi,pi,pi,1,1,100,pi,100,100,100];
    lambda_default = [0.005,0.005,0.005,1,1,0,0,0,0,0,0,0,0,0,0];
    switch shape
        case 'free' 
            lambda_fixed = [];
        case 'mallet_handle'           
            lambda_fixed = [1 2 3 4 5; 0.017 0.013 0.1 0.1 1];    
        case 'mallet_head'           
            lambda_fixed = [1 2 3 4 5; .05 .05 0.1 0.1 1];
        case 'hammer_handle'           
            lambda_fixed = [1 2 3 4 5; 0.017 0.013 0.08 0.1 1];    
        case 'hammer_scheibe'           
            lambda_fixed = [1 2 3 4 5; 0.016 .016 0.017 0.1 1];
        case 'frying_pan_bowl'
           lambda_fixed = [1,2,3,4,5; 0.15, 0.15, 0.015, 0.1, 1];
        case 'spatula_handle'
           lambda_fixed = [1 2 3 4 5; 0.0017 0.0083 0.0833 0.1 0.1];
        case 'spatula_blade'
            tapering_out = 0;
               tapering_in = 1;
           lambda_fixed = [1 2 3 4 5 9 10; 0.05 0.035 0.0017 0.2 0.1 -.2 -.2]; 
           lambda_upper_def(3) = 0.0025;
        case 'chopstick_handle'
           lambda_fixed = [1 2 3 4 5; 0.004 0.004 0.02 0.1 1];
        case 'chopstick_tip' 
           tapering_out = 0;
           tapering_in = 1;
           lambda_fixed = [1 2 3 4 5 9 10; 0.003 0.003 0.07 0.1 1 -0.5 -0.5];
        case 'teaspoon_handle'
           lambda_fixed = [1 2 3 4 5; 0.0075 0.005 0.05 0.1 1];
        case 'teaspoon_bowl'
           lambda_fixed = [1 2 3 4 5; 0.025 0.015 0.005 0.1 1];
        case 'retrieving_tool_handle'
           lambda_fixed = [1 2 3 4 5; 0.01 0.01 0.05 0.1 1];
        case 'retrieving_tool_tip'
           lambda_fixed = [1 2 3 4 5; 0.01 0.01 0.1 0.1 1];
        case 'super_egg'
            lambda_fixed = [1 2 3 4 5; 0.005 0.005 0.04 1 1];
        case 'small_sphere'
            lambda_fixed = [1 2 3 4 5; 0.005 0.005 0.005 1 1];
        case 'sphere'
            lambda_fixed = [1 2 3 4 5; 0.02 0.02 0.02 1 1];
        case 'small_handle'
            lambda_fixed = [1 2 3 4 5; 0.004 0.005 0.025 0.1 1];
        case 'medium_handle'
            lambda_fixed = [1 2 3 4 5; 0.0075 0.0075 0.04 0.1 1];
        case 'cylinder'
            lambda_fixed = [4 5; 0.1 1];
        case 'big_handle'
            lambda_fixed = [1 2 3 4 5; 0.01 0.01 0.08 0.1 1];
        case 'big_thick_handle'
            lambda_fixed = [1 2 3 4 5; 0.015 0.015 0.05 0.1 1];
        case 'big_thicker_handle'
            lambda_fixed = [1 2 3 4 5; 0.02 0.02 0.08 0.1 1];
        case 'stretchable_handle'
            lambda_fixed = [1 2 4 5; 0.01 0.01 0.1 1];
            lambda_upper_def(3) = 0.10;        
        case 'hammer_head'
            lambda_fixed = [1,2,3,4,5; 0.012, 0.012, 0.05, 0.1, 1];        
        case 'large_disc'
            lambda_fixed = [1,2,3,4,5; 0.15, 0.15, 0.015, 0.1, 1];
        case 'scheibe'
            lambda_fixed = [1 2 3 4 5; 0.010 0.010 0.01 0.1 1];
            part_type = 'extremity';
    end
    if ~tapering_in
        aux_lambda_fixed = zeros(2,length(lambda_fixed)+2);
        if ~isempty(lambda_fixed)
            aux_lambda_fixed(:,1:length(lambda_fixed)) = lambda_fixed;
        end
        aux_lambda_fixed(:,length(lambda_fixed)+1:length(lambda_fixed)+2) = [9 10; 0 0];
        lambda_fixed = aux_lambda_fixed;     
    end
    if ~bending
        aux_lambda_fixed = zeros(2,length(lambda_fixed)+2);
        if ~isempty(lambda_fixed)
            aux_lambda_fixed(:,1:length(lambda_fixed)) = lambda_fixed;
        end
        aux_lambda_fixed(:,length(lambda_fixed)+1:length(lambda_fixed)+2) = [11 12; 0 0];
        lambda_fixed = aux_lambda_fixed;           
    end
end