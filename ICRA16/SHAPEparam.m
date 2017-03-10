% hammer= [3, {ba1, ba2, ba3, 0.1, 1}, {SQUAREROOT((bpx-hpx)^2 + (bpy-hpy)^2 + (bpz-hpz)^2), [x1+1.57 y1 z1]}, {ha1, ha2, ha3, 0.1, e1}, {SQUAREROOT((hpx-cpx)^2 + (hpy-cpy)^2 + (hpz-cpz)^2), [x2 y2 z2]}, {ca1, ca2, ca3, 2, e2}];

%
% return SQ params (fixed and lower/upper bounds) according to the shape
%
% flags for tapering and bending further define lambda fixed
%
% Where:   lambda - variables, which should be found:
%               lambda(1)-(3) - Scale (a1-a3)
%               lambda(4)-(5) - Shape (epsilon1 and 2)
%               lambda(6)-(8) - Euler angles (phi, theta, psi in ZYZ)
%               lambda(9)-(10) - z-axis Tapering params (K_x,K_y)
%               position is never returned as a fixed or bound parameter
function [segments, angles, distances, weights] = SHAPEparam(object)   
    switch object
        case 'free_hammer'
            segments = {'free', 'free'};            
            %angles={{angle between segment a&b, lower_bound, upper_bound, angle of vector from center of part_a to part_b}, (repeat)}
            angles ={{pi/2, pi/4, 3*pi/4, pi/12}};            
            %distances={ditance between segment a&b, lower_bound, upper_bound}
            distances ={{0.2, 0.1, 0.3}};            
            %weights for the linear combination to calculate quality of fit
            weights = {[1; 1; 1; 1; 1; 1]}; 
        case 'mallet'
            segments = {'mallet_handle', 'mallet_head'};            
            %angles={{angle between segment a&b, lower_bound, upper_bound, angle of vector from center of part_a to part_b}, (repeat)}
            angles ={{pi/2, pi/4, 3*pi/4, 0}};            
            %distances={ditance between segment a&b, lower_bound, upper_bound}
            distances ={{0.15, 0.1, 0.3}};            
            %weights for the linear combination to calculate quality of fit
            weights = {[1; 1; 1; 1; 1; 1]};   
        case 'hammer'
            segments = {'hammer_handle', 'hammer_scheibe'};            
            %angles={{angle between segment a&b, lower_bound, upper_bound, angle of vector from center of part_a to part_b}, (repeat)}
            angles ={{pi/2, pi/4, 3*pi/4, pi/12}};            
            %distances={ditance between segment a&b, lower_bound, upper_bound}
            distances ={{0.24, 0.1, 0.3}};            
            %weights for the linear combination to calculate quality of fit
            weights = {[1; 1; 1; 1; 1; 1]};          
        case 'spatula'
            segments = {'spatula_handle', 'spatula_blade'};
            angles ={{1.27, 0, pi/2,-0.09}};
            distances ={{0.12, 0.05, 0.3}};
            weights = {[1; 1; 1; 1; 1; 1]};  
        case 'chopstick'
            segments = {'chopstick_handle', 'chopstick_tip'};
            angles ={{0, 11*pi/10, pi/10, 0}};
            distances ={{0.09, 0.05, 0.12}};
            weights = {[1; 1; 1; 1; 1; 1]}; 
        case 'teaspoon'
            segments = {'teaspoon_handle', 'teaspoon_bowl'};
            angles ={{1.15, 0, pi/2,0}};
            distances ={{0.09, 0.05, 0.12}};
            weights = {[1; 1; 1; 1; 1; 1]};  
        case 'retrieving_tool'
            segments = {'retrieving_tool_handle', 'retrieving_tool_tip'};
            angles ={{0, 11*pi/10, pi/10, 0}};
            distances ={{0.15, 0.05, 0.5}};
            weights = {[1; 1; 1; 1; 1; 1]};          
        case 'free'
            segments = {'all', 'all'};
            angles ={{0, 0, 2*pi}};
            distances={[0.1, 0, 100]};
            weights = {[1; 1; 1; 1; 1; 1]};            
    end    
end