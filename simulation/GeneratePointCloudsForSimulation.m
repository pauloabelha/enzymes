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
    n_iter = numel(pcl_filenames);
    disp('Checlking if there are any point clouds without p-tools');
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