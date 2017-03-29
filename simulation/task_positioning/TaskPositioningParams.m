function [ params, positioning_function ] = TaskPositioningParams( task_name )
    arm_length = 0.3;
    switch task_name
        case 'hammering_nail'
            %  planar_hitting_pos, arm_length 
            params = {[0.325 0 0.07], arm_length};
            positioning_function = 'hammering_positioning';
            return;
        case 'lifting_pancake'
            %  box (x y z), dist_x_tool_box, arm_length 
            params = {[0.3495, 0, 0.1],0.1,arm_length};
            positioning_function = 'lifting_positioning';
            return;
        case 'rolling_dough'
            %  dough_bottom_centre, dough_dist, arm_length 
            params = {[0.7 0 0.78],0.1,arm_length};
            positioning_function = 'rolling_positioning';
            return;   
        case 'cutting_lasagna'
            %  lasagna pos, lasagna dist, arm_length 
            params = {[0.75 0 0.775],0.15,arm_length};
            positioning_function = 'cutting_positioning';
            return;        
        case 'scooping_grains'
            %  Grain Box lower corner pos, approaching angle (radians), arm_length
            box_pos = [0.4 0 0.775];    
            box_size = [0.2, 0.25, 0.1];
            box_thickness = 0.01;
            params = {box_pos, box_size, box_thickness, 110*(pi/180), arm_length};
            positioning_function = 'scooping_positioning';
            return; 
    end
    error(['Could not find params and positioning function for task named ' task_name]);


end

