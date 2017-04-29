function [ elbow_pos, tool_relative_pos, tool_rot, action_tracker_pos ] = scooping_positioning( ptool, task_params, P )
    safe_dist = [0.005 0 0.001];
    min_grasp_dist_x = 0.1;
    %% get task params
    box_pos = task_params{1};
    box_size = task_params{2};
    box_thickness = task_params{3};    
    tool_rot = [0 0 0];
    [SQ_grasp, SQ_action] = GetPToolsSQs(ptool,'scooping_grains');    
    vec_centres = SQ_action(end-2:end) - SQ_grasp(end-2:end); 
    min_grasp_dist_x = max(min_grasp_dist_x,vec_centres(1));
    tool_relative_pos = [min_grasp_dist_x 0 0]; 
    action_length_z = min(abs(min(P.v(:,3))),SQ_action(:,3));
    %% get positioning
    box_x_pos = box_pos(1) -box_size(2)/2 + box_thickness;
    xi = box_x_pos + safe_dist(1) + action_length_z;
    zf = box_pos(3) + box_thickness + safe_dist(3) + max(P.v(:,1)) + action_length_z + min_grasp_dist_x(1);
    elbow_pos = [xi 0 zf];
    action_tracker_pos = elbow_pos + tool_relative_pos + vec_centres + [0 0 -action_length_z];
end

