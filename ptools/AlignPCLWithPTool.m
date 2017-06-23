% align a pcl with a given ptool
function P = AlignPCLWithPTool( P, ptool, ptool_map, plot_fig )
    % default is not plotting
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    orig_grasp_centre = ptool_map(1:3);
    orig_vec_grasp = ptool_map(4:6);
    % get the ptool SQs
    [ SQ_grasp, SQ_action ] = GetPToolsSQs( ptool );
    vec_grasp = GetSQVector( SQ_grasp );
    % get rotation matrix to align
    r = vrrotvec(vec_grasp,orig_vec_grasp);
    rm = vrrotvec2mat(r);
    % align grasping SQ
    SQ_grasp = RotateSQWithRotMtx(SQ_grasp,rm);
    SQ_grasp(end-2:end) = orig_grasp_centre;
    % align action SQ
    vec_centres = ptool(19:21)';
    new_vec_centres = rm*vec_centres;
    SQ_action = RotateSQWithRotMtx(SQ_action,rm);
    SQ_action(end-2:end) = SQ_grasp(end-2:end) + new_vec_centres';
    
    if plot_fig
        PlotPCLSegments(P);
        hold on;
        PlotSQs({SQ_grasp,SQ_action});
    end    
end





