function [ elbow_pos, tool_relative_pos, tool_rot, action_tracker_pos ] = lifting_positioning( ptool, task_params, P )
%LIFTING_POSITIONING returns the offsets for positioning the task in the simulation world

% elbow_pos is the pose of the elbow in gazebo world.
% tool_relative_pos is the pose of the pTool relative to the elbow pose.
    action_tracker_pos = [0 0 0];
    small_diff = 0.0001;
    %% get task params
    box = task_params{1};
    dist_x_tool_box = task_params{2};
    arm_length = task_params{3};
    if ~exist('P','var')
        P = PTool2PCL(ptool);
    end
    %% get desired rotation 
    theta_attack = pi/20;
    %% elbow starts at the origin and is moved as necessary
    elbow_pos = [0 0 0];
    %% get ptool's SQs
    [SQ_grasp, SQ_action] = GetPToolsSQs(ptool,'lifting_pancake');
    %% get necessary distances
    % distance between the grasp and action part centres projected on
    % the X axis
    centre_grasp = SQ_grasp(end-2:end);
    centre_action = SQ_action(end-2:end);
    d_g_a = abs(centre_action - centre_grasp);
    %% discover which vector of the SQ (X or Y) is closest to the X axis
    a = sum(abs(GetSQVector(SQ_action,1)) - [1;0;0]);
    b = sum(abs(GetSQVector(SQ_action,2)) - [1;0;0]);
    if a < b
        scale_ix = 1;
    else
        scale_ix = 2;
    end
    %% get the action part scale size in its dimension aligned with the X axis
    a_x = SQ_action(scale_ix);
    %% get elbow X
    elbow_pos(1) = box(1) - (d_g_a(1) + a_x + dist_x_tool_box);
    %% get elbow Z
    elbow_pos(3) = box(3) + small_diff + SQ_action(3) + d_g_a(3) + arm_length;    
    %% Tool pos relative to rotation centre pos
    tool_relative_pos = [0 0 -arm_length];
    %% rotate tool around Y to get a better incidence (attack) angle
    tool_rot = [0 theta_attack 0];
    rot_theta = GetRotMtx(theta_attack,'y');
    centre_lowest_pt_vec = rot_theta*[max(P.v(:,1)); 0; 0];
    elbow_pos(3) = elbow_pos(3) - centre_lowest_pt_vec(3);
    P = Apply3DTransfPCL(P,{rot_theta});
    %% get the minimum Z of the poins that are 1cm before the tip of the tool
    min_action_Z = min(P.v(P.v(:,1)>max(P.v(:,1))-0.1,3));
    pcl_min_z = elbow_pos(3) + tool_relative_pos(3) + min_action_Z;
    desired_height = box(3)+small_diff;
    elbow_pos(3) = elbow_pos(3) + (desired_height - pcl_min_z);
end