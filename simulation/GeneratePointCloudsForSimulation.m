function [ ptools, ptools_maps, Ps, pcl_filenames ] = GeneratePointCloudsForSimulation( root_folder, simulation_rootfolder, task, extracted_ptools_filename )
    task_ = task;
    if exist('extracted_ptools_filename','var')
        load([root_folder extracted_ptools_filename]);
    else
        [ ptools, ptools_maps, Ps, pcl_filenames ] = ExtractPToolsFromFolder( root_folder, task );
    end
    task = task_; 
    n_iter = numel(pcl_filenames);
    parfor i=1:n_iter
        simulation_folder = [simulation_rootfolder GetPCLShortName(pcl_filenames{i}) '/'];
        GeneratePCLsWPToolsForSim( simulation_folder, ptools{i}, task, Ps{i}, ptools_maps{i} );
    end
    backup_filepath = [root_folder 'ptool_generation_data_' date '.mat'];
    disp(['Saving generated ptools to: ' backup_filepath]);
    save(backup_filepath);
end