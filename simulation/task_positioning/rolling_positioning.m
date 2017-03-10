function [ p_c_g, tool_rel_pos, tool_rot, p_c_a ] = rolling_positioning( ptool, task_params, P)
    
    small_diff = 0.0005;
    tool_rel_pos = [0 0 0];
    tool_rot = [0 0 0];
    
    %% get task params
    dough_contact_pos = task_params{1};
    dough_dist = task_params{2};
    arm_length = task_params{3};
    if ~exist('P','var')
        P = PTool2PCL(ptool);
    end
    %% get ptool's SQs
    [SQ_grasp, SQ_action] = GetPToolsSQs(ptool,'rolling_dough');
    vec_centres = SQ_action(end-2:end) - SQ_grasp(end-2:end);
    %% discover which vector of the SQ (X or Y) is closest to the X axis
    a = sum(abs(GetSQVector(SQ_action,1)) - [0;0;1]);
    b = sum(abs(GetSQVector(SQ_action,2)) - [0;0;1]);
    if a < b
        scale_az_ix = 1;
        scale_ax_ix = 2;
    else
        scale_az_ix = 2;
        scale_ax_ix = 1;
    end
    %% get the action part scale size in its dimension aligned with the X axis
    a_z = SQ_action(scale_az_ix);
    a_x = SQ_action(scale_ax_ix);
    %% get elbow X    
    p_c_a = dough_contact_pos + [-(dough_dist+a_x) 0 a_z+small_diff];  
    p_c_g = p_c_a - vec_centres;
end

