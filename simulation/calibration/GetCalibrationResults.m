function [ tool_names, best_ptool_scores, best_ptool_categ_scores, task_gt, accuracy_best,accuracy_categs,metric_1 ] = GetCalibrationResults( dataset_folder, calib_res_file )    
    load([dataset_folder calib_res_file]);
     %% get groundtruth for existing tools
    [ tool_names, ~, task_groundtruth ] = ReadGroundTruth([dataset_folder 'groundtruth_' task '.csv']);
    %% check for incongruency
    task_gt = [];
    for i=1:numel(tools)
        tool = tools{i};
        if numel(tool.ptool_median_scores) ~= size(tool.ptools,1)
            warning(['Tool ' tool.name ' has a different number of ptools than the original extracted one.']);
        end
            for j=1:numel(tool_names)
                if strcmp(tools{i}.name,tool_names{j})
                    task_gt(end+1) = task_groundtruth(j);
                    break;
                end
            end
    end
    if numel(task_gt) ~= numel(best_ptool_scores)
        error('Number of tools is inongruent');
    end    
    best_ptool_categ_scores = TaskCategorisation(best_ptool_scores,task);
    [accuracy_best,accuracy_categs,metric_1] = PlotTestResults( best_ptool_scores, best_ptool_categ_scores, task_gt, tool_names  );
end