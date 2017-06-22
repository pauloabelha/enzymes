function [ ptools, ptools_maps, Ps, pcl_filenames ] = GeneratePointCloudsForSimulation( root_folder, simulation_rootfolder, task, extracted_ptools_filename, completing )
    if ~exist('completing','var')
        completing = 0;
    end
    task_ = task;
    if exist('extracted_ptools_filename','var')
        load([root_folder extracted_ptools_filename]);
    else
        [ ptools, ptools_maps, Ps, pcl_filenames ] = ExtractPToolsFromFolder( root_folder, task );
    end
    task = task_; 
    if ~exist('Ps','var')
        Ps = cell(1,numel(pcl_filenames));
        pcl_filenames = FindAllFilesOfType(exts,root_folder);        
        % check that every pcl in folder has a corresponding groundtruth
        tot_toc = 0;
        for i=1:numel(pcl_filenames)
            tic;
            pcl_shortname = GetPCLShortName(pcl_filenames{i});
            Ps{i} = ReadPointCloud([root_folder pcl_filenames{i}]);
            found_pcl_name = 0;
            for j=1:numel(tool_names)
                if strcmp(pcl_shortname,tool_names{j})
                    found_pcl_name = 1;
                    break;                
                end
            end
            if ~found_pcl_name
                error(['Could not find groundtruth for pcl ' pcl_filenames{i}]);
            end
            tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,numel(pcl_filenames),'Reading pcls from folder: ');
        end
    end
    n_iter = numel(pcl_filenames);
    disp('Checking if there are any point clouds without p-tools');
    for i=1:n_iter
        if isempty(ptools{i})
            error(['Pointcloud #' num2str(i) ' ' pcl_filenames{i} ' has no p-tools']);
        end
    end
    parfor i=1:n_iter
        simulation_folder = [simulation_rootfolder GetPCLShortName(pcl_filenames{i}) '/'];
        GeneratePCLsWPToolsForSim( simulation_folder, ptools{i}, task, Ps{i}, ptools_maps{i}, completing );
    end
    backup_filepath = [root_folder 'ptool_generation_data_' date '.mat'];
    disp(['Saving generated ptools to: ' backup_filepath]);
    save(backup_filepath);
end