% extract the p-tool given a grasping and an action SQs
% also collects the transformations necessary to bring a pcl to the same
% ptool canonical rotation and position
function [ptool,orig_grasp_centre,orig_vec_grasp] = ExtractPTool(SQ_grasp,SQ_action,mass)    
    %% check params
    if ~exist('SQ_grasp','var') || ~exist('SQ_action','var')
        error('This function needs two SQs as its first two params');
    end
    CheckNumericArraySize(SQ_grasp,[1 15]);
    CheckNumericArraySize(SQ_action,[1 15]);
    %% check if mass is number
    CheckNumericArraySize(mass,[1 1]);
    SQ_grasp = AdjustMinimaPToolSQ(SQ_grasp);
    SQ_action = AdjustMinimaPToolSQ(SQ_action);
    %% rotate SQs to the canonical position
    % get original vectors for action and between centres
    orig_vec_grasp = GetSQVector(SQ_grasp);    
    orig_vec_centres = SQ_action(end-2:end)' - SQ_grasp(end-2:end)';
    [SQ_grasp, grasp_rot] = AlignSQWithVector( SQ_grasp, [0;0;1] );
    % rotate the action SQ with the new grasp rotation
    SQ_action = RotateSQWithRotMtx( SQ_action, grasp_rot );
    vec_centres = grasp_rot*orig_vec_centres;
    % move tool by moving grasp to origin
    orig_grasp_centre = SQ_grasp(end-2:end);
    SQ_grasp(end-2:end) = [0 0 0];
    SQ_action(end-2:end) = vec_centres;
    %% construct the 25-dimensional ptool vector
    ptool_grasp = [SQ_grasp(1:5) SQ_grasp(9:10) SQ_grasp(11:12)];
    ptool_action = [SQ_action(1:5) SQ_action(9:10) SQ_grasp(11:12)];
    ptool = [ptool_grasp ptool_action vec_centres' SQ_action(6:8) mass];
end