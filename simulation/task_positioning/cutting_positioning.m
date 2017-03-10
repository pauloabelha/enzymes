function [ elbow_pos, tool_relative_pos, tool_rot, action_tracker_pos ] = cutting_positioning( ptool, task_params, P )
    %% safe dist form table
    safe_dist = 0.0001;
    %% get task params
    lasagna_pos = task_params{1};
    lasagna_dist = task_params{2};
    arm_length = task_params{3};
    if ~exist('P','var')
        P = PTool2PCL(ptool);
    end
    elbow_pos = [0 0 0];
    elbow_pos(1) = lasagna_pos(1) - arm_length - lasagna_dist;
    [~,SQ_action] = GetPToolsSQs(ptool,'cutting_lasagna')
    elbow_pos(2) = elbow_pos(2) - SQ_action(end-1);
    elbow_pos(3) = lasagna_pos(3) + safe_dist - min(P.v(:,3));
    tool_rot = [0 0 0];
    tool_relative_pos = [arm_length 0 0];
    action_tracker_pos = [0 0 0];
    action_tracker_pos(1) = lasagna_pos(1) - lasagna_dist;
    action_tracker_pos(3) = lasagna_pos(3) + safe_dist;
end

