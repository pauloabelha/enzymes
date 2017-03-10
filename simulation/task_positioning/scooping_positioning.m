function [ elbow_pos, tool_relative_pos, tool_rot, action_tracker_pos ] = scooping_positioning( ptool, task_params, P )
    safe_dist = 0.02;
    %% get task params
    box_pos = task_params{1};
    box_size = task_params{2};
    box_thickness = task_params{3};    
    alpha = task_params{4};
    arm_length = task_params{5};
    if ~exist('P','var')
        P = PTool2PCL(ptool);
    end
    elbow_pos = [0 0 0];
    tool_rot = [0 0 0];
    %% get box lower inner wall corner    
    box_ref_point = box_pos - [box_size(1)/4 box_size(1)/2-box_thickness -box_thickness];
    %% get ptool's SQs
    [SQ_grasp, SQ_action] = GetPToolsSQs(ptool,'scooping_grains');
    %% get vector between centres
    vec_centres = SQ_action(end-2:end) - SQ_grasp(end-2:end);    
    %% get elbow pos
    rot_x = GetRotMtx(pi/2,'x');
    Q = Apply3DTransfPCL(P,{rot_x}); 
    safe_rot_y = min(Q.v(:,2));
    elbow_pos(1) = (box_ref_point(1) + safe_dist + SQ_action(3) + - min(P.v(:,3))) - arm_length;
    % add additional distance (x) according to the approach angle
    elbow_pos(1) = elbow_pos(1) + (arm_length - cos(alpha-pi/2)*arm_length);
    elbow_pos(2) = box_ref_point(2) + safe_dist - min(safe_rot_y,min(P.v(:,2)));
    elbow_pos(3) = box_ref_point(3) + safe_dist + max(P.v(:,1));
    % add additional height (z) according to the approach angle
    elbow_pos(3) = elbow_pos(3) + sin(alpha-pi/2)*arm_length;
    %% Tool pos relative to rotation centre pos
    tool_relative_pos = [0 0 arm_length];
    %% get container bottom pos
    SQ_action_pcl = UniformSQSampling3D(SQ_action,1,2000);
    [~,b] = min(SQ_action_pcl(:,2));
    action_tracker_pos = elbow_pos + tool_relative_pos + SQ_action_pcl(b,:);
end

