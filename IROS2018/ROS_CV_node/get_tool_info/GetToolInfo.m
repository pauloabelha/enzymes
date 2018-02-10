function [ P, SQs, ptools, ptool_maps, grasp_centre, action_centre, tool_tip, tool_quaternion ] = GetToolInfo( P, pcl_mass, target_obj_align_vec, target_obj_contact_point, task, gpr_task_path, verbose, parallel )
    SEGMENTATION_MANDATORY = 1;
    % set default outputs
    SQs=[];ptools=[];ptool_maps=[];grasp_centre=[];action_centre=[];tool_tip=[];complete_transf=[];
    % print help
    if ischar(P) && P == "--help"
        disp('Function GetToolInfo');        
        disp('This function will output all the necessary info for using a tool for a task'); 
        disp('The code should have come with .mat files corresponding to each available Task Function file.');
        disp([char(9) 'e.g. IROS2018_TaskFunction_scraping_butter.mat']); 
        disp('Params:'); 
        disp([char(9) 'First param: filepath to the point cloud']); 
        disp([char(9) 'Second param: mass of the pcl']);
        disp([char(9) 'Third param: target object alignment vector (final vector to which the tool''s vector going from grasp centre to action centre should be aligned)']);
        disp([char(9) 'Fourth param: target_obj_contact_point (final point to which the tool''s tip need to be translated (e.g. edge of a bowl for scraping butter)']);
        disp([char(9) 'Fifth param: task name (works only with ''scraping_butter'' for now)']);
        disp([char(9) 'Sixth param: path to the trained Task Function file']);
        disp([char(9) 'Seventh param: flag for verbose and logging (default is 0)']);
        disp([char(9) 'Eighth param: flag for running in parallel (default is 0)']);
        disp('Written by Paulo Abelha'); 
        return;
    end
    %% deal with inputs
    if ~exist('verbose','var')
        verbose = 0;
    else
        verbose = str2double(verbose);
    end
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
    if SEGMENTATION_MANDATORY && numel(P.segms) < 2
        disp(P);
        disp('ERROR: point cloud has less than two segments. Module requires segmented point cloud.');
        return;
    end
    if ~exist('pcl_mass','var')
        disp('Warning! No mass provided; default of 0.1 will be used');
        pcl_mass = 0.1;
    else
        pcl_mass = str2double(pcl_mass);
    end
    % try to parse target object alignment vector
    points_spilt = strsplit(target_obj_align_vec(2:end-1),';');
    target_obj_align_vec = zeros(3,1);
    for i=1:3
        point_str = strsplit(points_spilt{i},' ');
        target_obj_align_vec(i) = str2double(point_str);
    end   
    % try to parse target object contact point
    points_spilt = strsplit(target_obj_contact_point(2:end-1),' ');
    target_obj_contact_point = zeros(1,3);
    for i=1:3
        point_str = strsplit(points_spilt{i},' ');
        target_obj_contact_point(i) = str2double(point_str);
    end 
    if ~exist('parallel','var')
        parallel = 0;
    else
        parallel = str2double(parallel);
    end
    if parallel
        if verbose
            disp('Deleting previous parallel pool...');
        end
        delete(gcp('nocreate'));
        if verbose
            toc;
        end
        parpool;
        if verbose
            toc;
        end
    end
    % print inputs
    if verbose
        disp('Inputs:');
        disp('Point cloud:');
        disp(P);
        disp('Mass:');
        disp(pcl_mass);
        disp('Target Object Alinment Vector:');
        disp(target_obj_align_vec');
        disp('Target Object Contact Point:');
        disp(target_obj_contact_point);
        disp('Task Name:');
        disp(task);
        disp('Task Function Filepath:');
        disp(gpr_task_path);
        disp('Verbose:');
        disp(verbose);
        disp('Parallel:');
        disp(parallel);
    end
    %% load GPR for task
    if verbose
        disp('begin_log');
        disp('Loading Gaussian Process Regression object for task...');
    end
    try
        load(gpr_task_path);
    catch
        error(['Unable to locate Task Function file at: ' gpr_task_path]);
    end
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
    if best_SQs(2,end-2) > best_SQs(1,end-2)
        [~,tool_tip_ix] = max(P.v(:,1));
    else
        [~,tool_tip_ix] = min(P.v(:,1));
    end    
    % get tool tip
    tool_tip = P.v(tool_tip_ix,:);
    disp('tool_tip');
    disp([num2str(tool_tip)]);
    % get tool tip vector (grasp centre to tool tip)
    disp('tool_tip_vector');
    tool_tip_vector = [tool_tip - grasp_centre]';
    disp([num2str(tool_tip_vector')]);
    % get complete transformation
    tool_rot = vrrotvec2mat_(vrrotvec_(tool_tip_vector, target_obj_align_vec));
    disp('tool_quaternion');
    tool_tip_rot = [tool_rot*tool_tip']';
    tool_transl_vec = [target_obj_contact_point - tool_tip_rot]';
    tool_transf = GetTransfFromRotAndTransl(tool_rot, tool_transl_vec);
    tool_quaternion = rotm2quat_(tool_rot);
    disp(tool_quaternion);
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
        Q = Apply3DTransfPCL({P},{tool_transf});
        PlotPCLSegments(Q,-1,0);
        disp('Transformed point cloud''s segments are coloured (red, green, blue, yellow, ...)');
        hold on;
        scatter3(grasp_centre(1),grasp_centre(2),grasp_centre(3),sphere_plot_size,'.g');
        disp('Original grasp centre point as a green sphere');
        scatter3(tool_tip(1,1),tool_tip(1,2),tool_tip(1,3),sphere_plot_size,'.b');
        disp('Original tool tip point as a blue sphere');
        transf_tool_tip = TransformPoints(tool_transf, tool_tip);
        scatter3(transf_tool_tip(1,1),transf_tool_tip(1,2),transf_tool_tip(1,3),sphere_plot_size,'.c');
        disp('Transformed tool tip point as a cyan sphere');
        transf_grasp_centre = TransformPoints(tool_transf, grasp_centre);
        scatter3(transf_grasp_centre(1,1),transf_grasp_centre(1,2),transf_grasp_centre(1,3),sphere_plot_size,'.m');
        disp('Transformed grasp centre point as a magenta sphere');
    end
end

