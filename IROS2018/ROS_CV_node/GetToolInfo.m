function [ P, SQs, ptools, ptool_maps, grasp_centre, action_centre, tool_tip, complete_transf ] = GetToolInfo( P, pcl_mass, task, gpr_task_path, verbose )
    % print help
    if ischar(P) && P == "--help"
       disp('Function GetToolInfo');        
       disp('This function will output all the necessary info for using a tool for a task'); 
       disp([char(9) 'First param: filepath to the point cloud']); 
       disp([char(9) 'Second param: mass of the pcl']);
       disp([char(9) char(9) 'One point: "[0.1 0.1 0.1]"']);
       disp([char(9) char(9) 'Two point: "[0.1 0.1 0.1;0.2 0.2 0.2]"']);
       disp([char(9) char(9) 'Three point: "[0.1 0.1 0.1;0.2 0.2 0.2;0.3 0.3 0.3]"']);
       disp([char(9) char(9) 'The double quote around the list of points is required']);
       disp([char(9) 'Third param: 1 or 0 for whether to print the edges to the terminal (default is 1)']);
       disp([char(9) 'Fourth param: 1 or 0 for whether to plot the results (default is 0)']);
       disp([char(9) 'Fifth param: 1 or 0 for whether to run the superquadric fitting in parallel (default is 0)']);
       disp([char(9) char(9) 'Setting the parallel param to 1 may incur in a long waiting time to create a parallel pool of cores']);
       disp('')
       disp('Example calls:');
       disp([char(9) './edge_detector ~/ToolWeb/bowl_2_3dwh.ply "[0.1 0.1 0.1;0.2 0.2 0.2]" 0 1 0']);
       disp([char(9) 'This will cal edge_detector on the given point cloud, using two points, plot the results, and running serially']);
       disp('')
       disp('Example calls:');
       disp([char(9) './edge_detector ~/ToolWeb/bowl_2_3dwh.ply "[0.1 0.1 0.1;0.2 0.2 0.2;0.3 0.3 0.3]"']);
       disp([char(9) 'This will cal edge_detector on the given point cloud, using three points and print the edges to the terminal']);
       disp('')
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
    end
    if ~exist('verbose','var')
        verbose = 0;
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
    [ best_scores, best_categ_scores, best_ptools, best_ptool_maps, best_ixs, SQs_ptools, ERRORS_SQs_ptools ] = SeedProjection( P, pcl_mass, task, @TaskFunctionGPR, {gprs{end}, dims_ixs{end}}, 0, 0, 1, verbose );  
    best_score = best_scores(best_weight_ix);
    best_categ_score = best_categ_scores(best_weight_ix);
    best_ptool = best_ptools(best_weight_ix,:);
    best_ptool_map = best_ptool_maps(best_weight_ix,:);
    best_SQs = SQs_ptools{best_ixs(best_weight_ix)};
    best_ERRORS_SQs_ptools = ERRORS_SQs_ptools{best_ixs(best_weight_ix)};
    if verbose
        toc;
    end
    %% fit SQs
    if verbose
        disp('Fitting SQs...');
    end
    [SQs, ~, ERRORS_SQs] = PCL2SQ(P, 1);
    if verbose
        toc;
    end
    %% get ptools
    if verbose
        disp('Extracting ptools...');
    end
    if numel(P.segms) == 1
        [ ptools, ptool_maps, ptool_errors ] = ExtractPTool(SQs{1},SQs{1}, pcl_mass,ERRORS_SQs);
    else
        [SQs_alt, ERRORS_SQs_alt] = GetRotationSQFits( SQs, P.segms );
        [ ptools, ptool_maps, ptool_errors ] = ExtractPToolsAltSQs(SQs_alt, pcl_mass, ERRORS_SQs_alt);
    end
    if verbose
        toc;
    end
    % decide which part is grasping
    ptool_ix = 1;
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
    tool_tip = P.v(tool_tip_ix,:);
    disp('tool_tip');
    disp([num2str(tool_tip)]);
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
        disp('Plotting tool info...');
        PlotPCLSegments(P,-1,0,{'.k','.k','.k','.k','.k','.k','.k'});   
        disp('Original point cloud is in black');        
        PlotSQs(best_SQs,-1,-1,{'.b', '.y'});
        disp('Superquadrics fitted to the original point cloud are:');
        disp([char(9) 'Grasp part in blue']);
        disp([char(9) 'Action part in yellow']);
        PlotPCLSegments(Q,-1,0);
        disp('Transformed point cloud''s segments are coloured (red, green, blue, yellow, ...)');
    end
end

