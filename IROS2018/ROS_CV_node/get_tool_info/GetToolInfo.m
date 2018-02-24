function [ P, SQs_orig, best_ptool, grasp_centre, action_centre, tool_tip, tool_heel, tool_quaternion, affordance_score ] = GetToolInfo( P, pcl_mass, target_obj_align_vec, target_obj_contact_point, task, gpr_task_path, verbose, parallel )
    SEGMENTATION_MANDATORY = 1;
    % set default outputs
    SQs_orig=[];best_ptool=[];ptool_maps=[];grasp_centre=[];action_centre=[];tool_tip=[];tool_heel=[];tool_quaternion=[];affordance_score=[];
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
        disp('Written by Paulo Abelha Ferreira'); 
        return;
    end
    %% deal with inputs
    if ~exist('verbose','var')
        verbose = 0;
    else
        if ischar(verbose)
            verbose = str2double(verbose);
        end
    end
    if verbose
        tic;
        disp('begin_log');
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
        error('ERROR: point cloud has less than two segments. Module requires segmented point cloud.');
    end
    if ~exist('pcl_mass','var')
        disp('Warning! No mass provided; default of 0.1 will be used');
        pcl_mass = 0.1;
    else
        if ischar(pcl_mass)
            pcl_mass = str2double(pcl_mass);
        end
    end
    % try to parse target object alignment vector
    if ischar(target_obj_align_vec)
        points_spilt = strsplit(target_obj_align_vec(2:end-1),';');
        target_obj_align_vec = zeros(3,1);
        for i=1:3
            point_str = strsplit(points_spilt{i},' ');
            target_obj_align_vec(i) = str2double(point_str);
        end 
    end
    % try to parse target object contact point
    if ischar(target_obj_contact_point)
        points_spilt = strsplit(target_obj_contact_point(2:end-1),' ');
        target_obj_contact_point = zeros(1,3);
        for i=1:3
            point_str = strsplit(points_spilt{i},' ');
            target_obj_contact_point(i) = str2double(point_str);
        end 
    end
    if ~exist('parallel','var')
        parallel = 0;
    else
        if ischar(parallel)
            parallel = str2double(parallel);
        end
    end
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
    if parallel
        if verbose
            disp('Deleting previous parallel pool...');
        end
        %delete(gcp('nocreate'));
        if verbose
            toc;
        end
        %parpool;
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
        disp('Target Object Alignment Vector:');
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
    %% preprocess pcl to see if there are problematic segms
    if verbose
        disp('Preprocessing point cloud to check for problematic (small) segments.');
        disp(['Point cloud has ' num2str(numel(P.segms)) ' segments']);
    end
    MIN_N_PTS_IN_SEGM = 100;
    new_segms = {};
    n_problematic_segms = 0;
    for i=1:numel(P.segms)
        num_pts_in_segm = size(P.segms{i}.v,1);
        if num_pts_in_segm < MIN_N_PTS_IN_SEGM
            n_problematic_segms = n_problematic_segms + 1;
            if verbose
                disp(['Found problematic segment with only ' num2str(num_pts_in_segm) ' point(s): #' num2str(i)]);
                disp('This segment will not be considered');
            end            
        else
           new_segms{end+1} = P.segms{i}; 
        end
    end
    if numel(new_segms) < 2
        if verbose
            disp('Point cloud was left with only one segment; Aborting...');
            disp('end_log');
            return;
        end
    end
    if verbose
       if n_problematic_segms  == 0
           disp('Point cloud ok!');
       end
       toc;
    end
    P.segms = new_segms;
    %% load GPR for task
    if verbose        
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
    best_weight_ix = round(n_weight_tries/2)+10;
    if verbose
        disp('Performing projection...');
    end
    [ best_scores, best_categ_scores, best_ptools, best_ptool_maps, best_ixs, SQs_ptools, ERRORS_SQs_ptools, best_ptool_SQs_ixs, SQs_orig ] = SeedProjection( P, pcl_mass, task, @TaskFunctionGPR, {gprs{end}, dims_ixs{end}}, 0, 0, 1, verbose, 0, parallel );  
    best_score = best_scores(best_weight_ix);
    best_categ_score = best_categ_scores(best_weight_ix);
    best_ptool = best_ptools(best_weight_ix,:);
    best_ptool_map = best_ptool_maps(best_weight_ix,:);
    best_SQs = SQs_ptools{best_ixs(best_weight_ix)};    
    best_ERRORS_SQs_ptools = ERRORS_SQs_ptools{best_ixs(best_weight_ix)};
    best_ptool_SQs_ixs = best_ptool_SQs_ixs(best_weight_ix,:);
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
    %% finish log
    if verbose
        toc;
    end    
    %% get grasp part centre
    grasp_centre = SQ_grasp(end-2:end);
    %% get grasp and action segm ix
    grasp_segm_ix = best_ptool_SQs_ixs(2);
    action_segm_ix = best_ptool_SQs_ixs(4);
    %% get tool tip
    N_dist = pdist2(P.segms{action_segm_ix}.v,mean(P.segms{grasp_segm_ix}.v));
    [~, tool_tip_ix] = max(N_dist);
    %% get tool heel (e.g. in a knife, for scraping butter)    
    [~, tool_heel_ix] = min(N_dist);
    tool_heel = P.segms{action_segm_ix}.v(tool_heel_ix,:);
    %% get tool tip    
    tool_tip = P.segms{action_segm_ix}.v(tool_tip_ix,:);
    %% get tool tip vector
    tool_tip_vector = [tool_tip - grasp_centre]';
    %% get tool rotation
    tool_rot = vrrotvec2mat_(vrrotvec_(tool_tip_vector, target_obj_align_vec));
    tool_tip_rot = [tool_rot*tool_tip']';
    tool_transl_vec = [target_obj_contact_point - tool_tip_rot]';
    tool_transf = GetTransfFromRotAndTransl(tool_rot, tool_transl_vec);    
    affordance_score = best_categ_score;
    %% plot
%     if verbose
%         figure;
%         PlotPCLSegments(P,-1,0,{'.k','.k','.k','.k','.k','.k','.k'});
%         PlotSQs(SQs_orig);
%         figure;
%         sphere_plot_size = 5000;
%         disp('Plotting tool info...');
%         PlotPCLSegments(P,-1,0,{'.k','.k','.k','.k','.k','.k','.k'});   
%         disp('Original point cloud is in black');        
%         %PlotPtools(best_SQs,-1,-1,{'.b', '.y'});
% %         disp('Superquadrics fitted to the original point cloud are:');
% %         disp([char(9) 'Grasp part in blue']);
% %         disp([char(9) 'Action part in yellow']);
%         Q = Apply3DTransfPCL({P},{tool_transf});
%         PlotPCLSegments(Q,-1,0);
%         disp('Transformed point cloud''s segments are coloured (red, green, blue, yellow, ...)');
%         hold on;        
%         %% plot tool itip
%         scatter3(tool_tip(1,1),tool_tip(1,2),tool_tip(1,3),sphere_plot_size,'.m');
%         disp('Original tool tip point as a magenta sphere');
%         transf_tool_tip = TransformPoints(tool_transf, tool_tip);
%         scatter3(transf_tool_tip(1,1),transf_tool_tip(1,2),transf_tool_tip(1,3),sphere_plot_size,'.m');
%         disp('Transformed tool tip point as a magenta sphere');
%         %% plot tool heel (original and transformed)
%         scatter3(tool_heel(1,1),tool_heel(1,2),tool_heel(1,3),sphere_plot_size,'.y');
%         disp('Original tool heel point as a yellow sphere');
%         transf_tool_heel = TransformPoints(tool_transf, tool_heel);
%         scatter3(transf_tool_heel(1,1),transf_tool_heel(1,2),transf_tool_heel(1,3),sphere_plot_size,'.y');        
%         disp('Transformed tool heel point as a yellow sphere');
%         %% plot grasp centre (original and transformed)
%         scatter3(grasp_centre(1),grasp_centre(2),grasp_centre(3),sphere_plot_size,'.c');
%         disp('Original grasp centre point as a cyan sphere');
%         transf_grasp_centre = TransformPoints(tool_transf, grasp_centre);
%         scatter3(transf_grasp_centre(1,1),transf_grasp_centre(1,2),transf_grasp_centre(1,3),sphere_plot_size,'.c');
%         disp('Transformed grasp centre point as a cyan sphere');
%     end
    %% print tool info
%     disp('begin_tool_info');
%     disp('begin_input_params');
%     disp('point_cloud');
%     disp(P.filepath);
%     disp('mass');
%     disp(num2str(pcl_mass));
%     disp('target_obj_align_vec');
%     disp([num2str(target_obj_align_vec')]);
%     disp('target_obj_contact_pt');
%     disp([num2str(target_obj_contact_point)]);
%     disp('task');
%     disp(task);
%     disp('task_function_data_file');
%     disp(gpr_task_path);
%     disp('verbose');
%     disp(num2str(verbose));
%     disp('parallel');
%     disp(num2str(parallel));
%     disp('end_input_params');
%     % get affordance score
%     disp(['affordance_score' num2str(best_categ_score)]);%     
%     disp(num2str(best_categ_score));    
%     disp('grasp_segm');
%     disp(num2str(grasp_segm_ix));
%     disp('action_segm');
%     disp(num2str(action_segm_ix));
%     %% display grasp centre
%     disp('grasp_center');
%     disp(num2str(grasp_centre));
%     %% get action part centre
     action_centre = SQ_action(end-2:end);
%     disp('action_center');
%     disp(num2str(action_centre));
%     %% display tool tip
%     disp('tool_tip');
%     disp([num2str(tool_tip)]);
%     %% dispay tool tip vector (grasp centre to tool tip)
%     disp('tool_tip_vector');    
%     disp([num2str(tool_tip_vector')]);
%     %% display tool heel
%     disp('tool_heel');
%     disp([num2str(tool_heel)]);
%     %% get tool quaternion    
%     disp('tool_quaternion');
     tool_quaternion = rotm2quat_(tool_rot);
%     disp([num2str(tool_quaternion)]);
%     %% finish writing tool info
%     disp('end_tool_info'); 
end

