function [ elbow_pos, tool_relative_pos, tool_rot, action_tracker_pos ] = hammering_positioning( ptool, params, P )
    action_tracker_pos = [0 0 0];
    
    planar_hitting_pos = params{1};
    arm_length = params{2};
    
    [SQ_grasp, SQ_action] = GetPToolsSQs(ptool,'hammering_nail');
    
    dist_centres = pdist([SQ_action(end-2:end);SQ_grasp(end-2:end)]);
    vec_centres = [SQ_action(end-2:end) - SQ_grasp(end-2:end)]';
    vec_centres = UnitVector(vec_centres);
    vec_center_angle = acos(vec_centres(1));    
         
    elbow_pos(1) = planar_hitting_pos(1)  - (arm_length + dist_centres*sin(vec_center_angle));
    elbow_pos(2) = 0;
    elbow_pos(3) = planar_hitting_pos(3) + SQ_action(3) + dist_centres*cos(vec_center_angle); 
    
    tool_relative_pos = [0 0 arm_length];
    
end

