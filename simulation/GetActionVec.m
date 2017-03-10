%the action SQ may not be fitted according to the expected model
%this function will try to get the proper action vector
%by making it be the vector that goes from the projected center of actionSQ
%to the grasping axis
function [ action_vec] = GetActionVec(center_grasping, size_handle, center_action )
   %     center_grasping = model.grasp.central_point;
    %     center_grasping = center_grasping*pca_;
    %     center_grasping = center_grasping*Ry;
    %     center_action = model.action.central_point;
    %     center_action = center_action*pca_;
    %     center_action = center_action*Ry;
    
    model_base_central_point = [center_grasping(1) center_grasping(2) center_grasping(3)-size_handle];
    center_action_vec = center_action - model_base_central_point;
    center_action_vec_norm = center_action_vec/norm(center_action_vec);
    r = vrrotvec(center_action_vec_norm,[0;0;1]);
    rm = vrrotvec2mat(r);
    proj_center_action = center_action_vec*rm';
    action_vec = center_action-[center_grasping(1) center_grasping(2) model_base_central_point(3)+proj_center_action(3)];    
    
    
%     model_base_central_point = [center_grasping(1) center_grasping(2) center_grasping(3)-size_handle];
%     center_action_vec = center_action - model_base_central_point;
%     center_action_vec_norm = center_action_vec/norm(center_action_vec);
%     r = vrrotvec(center_action_vec_norm,[0;0;1]);
%     rm = vrrotvec2mat(r);
%     proj_center_action = center_action_vec*rm';
%     action_vec = center_action-[center_grasping(1) center_grasping(2) model_base_central_point(3)+proj_center_action(3)];




%     %project the action center onto the grasping axis
%     proj_center_action = [center_grasping(1:2) center_action(3)];
%     action_vec = center_action - proj_center_action;
%     %make it a unit vector
%     action_vec = action_vec/norm(action_vec);
%     action_vec = action_vec';
end

