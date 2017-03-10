%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
%
%% Simple version of VAS (Visual Analogy System) - one segmentation + best ptool for the task function
%  This function evaluates, for a given task, the best way to use and the affordance score of a point cloud 
%
% Inputs:
%   pcl_filepath - full path to the point cloud file to be assessed
%   task - name of the task (currently working only for 'hammering_nail'
% Outputs:
%   best_pTool - 24-dim vector with the best pTool for the pcl and task
%   affordance_score - affordance score for the ptool
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ best_pTool, pTools, pToolsStruct, all_affordance_scores, best_affordance_score, all_categ_scores, best_categ_score, mode_categ_score, best_pTool_ix, best_pTool_comb_ix ] = VAS_PureGPR( root_filepath, pcl_filename, tool_mass, task_name, gpr_task, write_ptool_sim, plot_fig )
    %% by default, do not plot figure
    if ~exist('plot_fig','var')
        plot_fig=0;
    end      
    %% by default, do not write the simulation-ready best pTool
    if ~exist('write_ptool_sim','var')
        write_ptool_sim=0;
    end   
    % get the pcl shortname 
    pcl_shortname = GetPCLShortName( pcl_filename );
    %% either segment the pointcloud or get segmented options from the folder 'segm_folder'
    if exist('segm_folder','var') && ~ischar(segm_folder)    
        % create temporary working directory
        temp_directory = 'temp/';
        temp_working_directory = [root_filepath temp_directory];
        mkdir(temp_working_directory);
        
        % copy the pcl to the temporary working directory
        command = ['cp ' root_filepath pcl_shortname '.ply ' temp_working_directory pcl_shortname '.ply '];
        system(command);
        % convert the pcl to .pcd
        command = ['~/pcl/release/bin/pcl_ply2pcd ' temp_working_directory pcl_filename ' -o ' temp_working_directory pcl_shortname '.pcd'];
        system(command);
        % start autosegmentation
        command = ['sudo ~/pcl/release/bin/pcl_example_cpc_segmentation ' temp_working_directory pcl_shortname '.pcd -fast -loop 1,1 -o ' temp_working_directory pcl_shortname ' -write'];
        system(command);
        % filter autosegmentation by free SQ fitting
        fit_threshold = 0.0075;
        n_good_segmentations = 0;
        while n_good_segmentations < 1 && fit_threshold <= 0.02
            n_good_segmentations = FilterAutoSegmentationsByFreeSQFitting( temp_working_directory, fit_threshold, 500, {''}, 'good_segmentations/' );
            fit_threshold = fit_threshold + 0.0025;
        end
        if fit_threshold > 0.02
           error(['Could not find any good segmentation option for the pointcloud ' pcl_filename]);  
        end
        command = ['rm ' temp_working_directory '*.*'];
        system(command);
        command = ['cp ' temp_working_directory 'good_segmentations/*.pcd ' temp_working_directory];
        system(command);
        segm_path = temp_working_directory;  
        % remove temporary working directory
        command = ['rm -r ' temp_working_directory];
        system(command);
        pcl_segm_file_ext = 'pcd';
    else
        if exist('segm_folder','var')
            segm_path = [root_filepath segm_folder];   
        else
            segm_path = root_filepath;
        end
        pcl_segm_file_ext = 'ply';
    end
    %% here there should >=1 segmented pcls in 'segm_path' 
    [ Ps, pTools, pToolsStruct, transfs_lists, pcl_filenames, ptool_ix_to_pcl_ix, ~ ] = GetPtoolsOnePclInFolder( pcl_shortname, segm_path, task_name, tool_mass, pcl_segm_file_ext, pcl_shortname );
    if isempty(pTools)
        error(['Could not extract any pTools from pcl ' pcl_shortname]);
    end

    %% here we should have all the p-tools for the pcl       
    %% get best pTool and best score
    all_affordance_scores = [];
    all_categ_scores = [];
    best_affordance_score = 0;
    best_pTool_ix = 0;
    best_pTool_comb_ix = 0;
    best_categ_score = 0;
    if size(gpr_task.ActiveSetVectors,2) == 29
        pTools = AddInertialToPtools(pTools,task_name);
    end
    for i=1:size(pTools,1)
        % get affordance score for the current pTool       
        predicted_score = gpr_task.predict(pTools(i,:));
        %predicted_score = round(predicted_score);
        all_affordance_scores(end+1) = predicted_score;
        %all_categ_scores(end+1) = TaskCategorisation( predicted_score, task_name );
        if predicted_score >=0 && predicted_score >= best_affordance_score
            best_affordance_score = predicted_score;
            best_categ_score = predicted_score;
            best_pTool_ix = i;
            best_pTool_comb_ix = i;
        end
    end    
    all_categ_scores = TaskCategorisation(all_affordance_scores,task_name);
    best_categ_score = all_categ_scores(best_pTool_ix);
    best_transf_list = transfs_lists{best_pTool_ix};
    best_pTool_struct = pToolsStruct{best_pTool_ix};
    best_pTool = getVector(best_pTool_struct);
    mode_categ_score = mode(all_categ_scores);    
    best_pcl_ix = ptool_ix_to_pcl_ix(best_pTool_ix);

    %% plot
%     n_comb = size(pTools,1);
%     n_segms = (1+sqrt((4*n_comb)+1))/2;
%     comb_segms = nchoosek(1:n_segms,2);
%     if mod(best_pTool_comb_ix,2)
%         grasp_action_ixs = comb_segms(round(best_pTool_comb_ix/2),:);        
%     else
%         grasp_action_ixs = [comb_segms(round(best_pTool_comb_ix/2),2) comb_segms(round(best_pTool_comb_ix/2),1)];
%     end   
    grasp_action_ixs = [best_pTool_struct.grasp.ix best_pTool_struct.action.ix];
    if write_ptool_sim   
        P = Ps{best_pcl_ix};
        P = AddColourToSegms(P);
        best_ptool_vec = getVector(best_pTool_struct);
        pToolVec2Sim( root_filepath, pcl_shortname, best_ptool_vec, task_name );
    end    
    if plot_fig
        P = ReadPointCloud([root_filepath pcl_filenames{best_pTool_ix}],500);
        figure;
        hold on; 
        axis equal;
        for i=1:size(P.segms,2)
            colour = [0.5 0.5 0.5];
            if i == grasp_action_ixs(1)
                colour = '.b';          
            end
            if i == grasp_action_ixs(2)
                colour = '.k';          
            end 
            if ~isempty(P.segms{i}.v)
                P.segms{i}.v = DownsamplePCL(P.segms{i}.v,2000);
                scatter3(P.segms{i}.v(:,1),P.segms{i}.v(:,2),P.segms{i}.v(:,3),50,colour);
            end
        end
        hold off;
        figure; plot(all_affordance_scores);
    end
end

