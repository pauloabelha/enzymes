function [ tools ] = MergeCalibrationResultsPtoolData( task, tool_scores, root_folder, ptool_data_filename )
    %% load ptool data file
    disp('Loading data...');
    task_ = task;
    load([root_folder ptool_data_filename]);
    task = task_;
    tools = {};
    tot_toc = 0;
    for i=1:numel(tool_scores)
        tic
        tool_name = tool_scores{i}.name;
        for j=1:numel(pcl_filenames)
           if strcmp(tool_name,GetPCLShortName(pcl_filenames{j}))
               tools{end+1}.name = tool_name;
               tools{end}.tool_scores = tool_scores{i};
               tools{end}.ptools = ptools{j};
               tools{end}.ptools_maps = ptools_maps{j};
               tools{end}.P = Ps{j};
           end
        end
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc + toc, i, numel(tool_scores), 'Merging calibration results: ');
    end
    clear i;
    clear j;
    clear P;
    clear pcl_filenames;
    clear Ps;
    clear ptool_data_filename;
    clear ptools;
    clear ptools_maps;
    clear tool_name;
    clear tool_scores;
    disp('Saving data file...');
    save([root_folder task '_tools_ptools_calibration.mat']);
end