% align a ptool with its pcl given the original grasping point
function [ SQ_grasp, SQ_action] = AlignPToolWithPCL( ptool, P, ptool_map, plot_fig )
    %% check params
    % default is not plotting
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    %% initialise variables
    transf_list = cell(1,2);
    orig_grasp_centre = ptool_map(1:3);
    orig_vec_grasp = ptool_map(4:6);
    %% get the ptool SQs
    [ SQ_grasp, SQ_action ] = GetPToolsSQs( ptool );        
   	%% get vectors
    vec_grasp = GetSQVector( SQ_grasp );
    vec_centres = ptool(19:21)';
     %% rotate SQs
    % get rotation matrix to align
    [ SQ_grasp, rot_SQ ] = AlignSQWithVector(SQ_grasp, orig_vec_grasp);
    SQ_action = RotateSQWithRotMtx(SQ_action, rot_SQ);
    %% translate SQs
    SQ_grasp(end-2:end) = orig_grasp_centre;
    
    new_vec_centres = rot_SQ*vec_centres;    
    SQ_action(end-2:end) = SQ_grasp(end-2:end) + new_vec_centres';
    if plot_fig
        PlotPCLSegments(P,-1,5000,{'.b', '.k'});
        hold on;
        PlotSQs({SQ_grasp,SQ_action},10000);
    end    
end