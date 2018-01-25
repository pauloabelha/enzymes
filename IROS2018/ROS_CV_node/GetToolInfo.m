function [ P, SQs, ptools, ptool_maps, grasp_centre, action_centre, tool_tip, complete_transf ] = GetToolInfo( P, pcl_mass, target_obj_align_vec_str, task, gpr_task_path, verbose, parallel )
    % print help
    if ischar(P) && P == "--help"
        disp('Function GetToolInfo');        
        disp('This function will output all the necessary info for using a tool for a task'); 
        disp([char(9) 'First param: filepath to the point cloud']); 
        disp([char(9) 'Second param: mass of the pcl']);
        disp([char(9) 'Third param: target object alignment vector']);
        disp([char(9) 'Fourth param: task name']);
        disp([char(9) 'Fifth param: path to the trained GPR']);
        disp([char(9) 'Sixth param: flag for verbose and logging (default is 0)']);
        disp([char(9) 'Sixth param: flag for running in parallel (default is 0)']);
        disp('Written by Paulo Abelha'); 
        return;
    end
    %% deal with inputs
    if verbose
        tic;
    end    
    % read pcl
    if verbose
        disp('Reading pcl...');
    end    
    try
        CheckIsPointCloudStruct(P);
    catch
        if ischar(P)
            P = ReadPointCloud(P);
        else
            PointCloud(P);
        end
    end
    if verbose
        toc;
    end
    if ~exist('pcl_mass','var')
        disp('Warning! No mass provided; default of 0.1 will be used');
        pcl_mass = 0.1;
    else
        pcl_mass = str2double(pcl_mass);
    end
    % try to parse points string
    points_spilt = strsplit(target_obj_align_vec_str(2:end-1),';');
    target_obj_align_vec = zeros(3,1);
    for i=1:3
        point_str = strsplit(points_spilt{i},' ');
        target_obj_align_vec(i) = str2double(point_str);
    end
    if ~exist('verbose','var')
        verbose = 0;
    else
        verbose = str2double(verbose);
    end
    if ~exist('parallel','var')
        parallel = 0;
    else
        parallel = str2double(parallel);
    end
    % print inputs
    if verbose
        disp('Inputs:');
        disp(P);
        disp(pcl_mass);
        disp(target_obj_align_vec_str);
        disp(task);
        disp(gpr_task_path);
        disp(verbose);
        disp(parallel);
    end
    %% load GPR for task
    if verbose
        disp('begin_log');
        disp('Loading Gaussian Process Regression object for task...');
    end
    load(gpr_task_path);
    if verbose
        toc;
    end    
    [~, ~, weights ] = ProjectionHyperParams;
    n_weight_tries = size(weights,1);
    best_weight_ix = round(n_weight_tries/2)+1;
    if verbose
        disp('Performing projection...');
    end
    [ best_scores, best_categ_scores, best_ptools, best_ptool_maps, best_ixs, SQs_ptools, ERRORS_SQs_ptools ] = SeedProjection( P, pcl_mass, task, @TaskFunctionGPR, {gprs{end}, dims_ixs{end}}, 0, 0, 1, verbose, 0, parallel );  
    best_score = best_scores(best_weight_ix);
    best_categ_score = best_categ_scores(best_weight_ix);
    best_ptool = best_ptools(best_weight_ix,:);
    best_ptool_map = best_ptool_maps(best_weight_ix,:);
    best_SQs = SQs_ptools{best_ixs(best_weight_ix)};
    best_ERRORS_SQs_ptools = ERRORS_SQs_ptools{best_ixs(best_weight_ix)};
    if verbose
        toc;
    end
%     %% fit SQs
%     if verbose
%         disp('Fitting SQs...');
%     end
%     [SQs, ~, ERRORS_SQs] = PCL2SQ(P, 1);
%     if verbose
%         toc;
%     end
%     %% get ptools
%     if verbose
%         disp('Extracting ptools...');
%     end
%     if numel(P.segms) == 1
%         [ ptools, ptool_maps, ptool_errors ] = ExtractPTool(SQs{1},SQs{1}, pcl_mass,ERRORS_SQs);
%     else
%         [SQs_alt, ERRORS_SQs_alt] = GetRotationSQFits( SQs, P.segms );
%         [ ptools, ptool_maps, ptool_errors ] = ExtractPToolsAltSQs(SQs_alt, pcl_mass, ERRORS_SQs_alt);
%     end
%     if verbose
%         toc;
%     end
    % decide which part is grasping
    % align ptool
    if verbose
        disp('Extracting pcl transformation');
    end
    [SQ_grasp, SQ_action] = AlignPToolWithPCL( best_ptool, P, best_ptool_map );
    %% get action end point
    transf_lists = PtoolsTaskTranfs( best_ptool, task );
    %PlotPCLSegments(P);
    Q = Apply3DTransfPCL({P},transf_lists);
    %PlotPCLSegments(P);
    if verbose
        toc;
    end   
    %% finish log writing
    if verbose
        disp('end_log');
    end    
    %% print tool info
    disp('begin_tool_info');
    % get affordance score
    disp('affordance_score');
    disp(num2str(best_categ_score));
    % get grasp part centre
    grasp_centre = SQ_grasp(end-2:end);
    disp('grasp_center');
    disp(num2str(grasp_centre));
    % get action part centre
    action_centre = SQ_action(end-2:end);
    disp('action_center');
    disp(num2str(action_centre));
    % get tool tip
    best_ptool(19:21)
    if best_SQs(2,end-2) > best_SQs(1,end-2)
        [~,tool_tip_ix] = max(P.v(:,1));
    else
        [~,tool_tip_ix] = min(P.v(:,1));
    end    
    % get tool tip
    tool_tip = P.v(tool_tip_ix,:)';
    disp('tool_tip');
    disp([num2str(tool_tip)]);
    % get tool tip vector (grasp centre to tool tip)
    tool_tip_vector = tool_tip - grasp_centre';
    disp('tool_tip_vector');
    disp([num2str(tool_tip_vector)]);
    rot_tool_tip = vrrotvec2mat_(vrrotvec_(tool_tip_vector, target_obj_align_vec));
    Q = Apply3DTransfPCL({P},{rot_tool_tip});
    % get complete transformation
    complete_transf = CombineTranfs(transf_lists);
    disp('tool_transf');
    disp(complete_transf);
    % finish writing tool info
    disp('end_tool_info'); 
    % finish log
    if verbose
        toc;
    end
    if verbose
        sphere_plot_size = 5000;
        disp('Plotting tool info...');
        PlotPCLSegments(P,-1,0,{'.k','.k','.k','.k','.k','.k','.k'});   
        disp('Original point cloud is in black');        
        %PlotPtools(best_SQs,-1,-1,{'.b', '.y'});
        disp('Superquadrics fitted to the original point cloud are:');
        disp([char(9) 'Grasp part in blue']);
        disp([char(9) 'Action part in yellow']);
        PlotPCLSegments(Q,-1,0);
        disp('Transformed point cloud''s segments are coloured (red, green, blue, yellow, ...)');
        hold on;
        scatter3(grasp_centre(1),grasp_centre(2),grasp_centre(3),sphere_plot_size,'.g');
        disp('Original grasp point as a green sphere');
        scatter3(tool_tip(1,1),tool_tip(2,1),tool_tip(3,1),sphere_plot_size,'.b');
        disp('Original tool tip as a blue sphere');
        transf_tool_tip = [rot_tool_tip [0;0;0]; 0 0 0 1]*[tool_tip;0];
        transf_tool_tip = transf_tool_tip(1:3);
        scatter3(transf_tool_tip(1,1),transf_tool_tip(2,1),transf_tool_tip(3,1),sphere_plot_size,'.m');
        disp('Transformed tool tip as a yellow sphere');
        transf_grasp_centre = [rot_tool_tip [0;0;0]; 0 0 0 1]*[grasp_centre';0];
        transf_grasp_centre = transf_grasp_centre(1:3);
        scatter3(transf_grasp_centre(1,1),transf_grasp_centre(2,1),transf_grasp_centre(3,1),sphere_plot_size,'.c');
        disp('Transformed grasp centre as a cyan sphere');
    end
end

