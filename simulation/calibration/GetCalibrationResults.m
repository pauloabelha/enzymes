function [ tool_names, best_ptool_scores, best_ptool_categ_scores, task_gt, tool_scores, tools, accuracy_best,accuracy_categs,metric_1, task, best_ptools_ixs ] = GetCalibrationResults( dataset_folder, output_filepath, tool_scores, task, best_ptool_scores, tools )    
    if ~exist('tool_scores','var') && ~exist('task','var') && ~exist('best_ptool_scores','var')
        [ tool_scores, task, ~, ~, best_ptool_scores, best_ptools_ixs_ ] = ReadCalibrationResults( output_filepath );
    end
    if ~exist('tools','var')
        tools = MergeCalibrationResultsPtoolData( task, tool_scores, dataset_folder, 'extracted_ptools.mat');
    end
     %% get groundtruth for existing tools
    [ tool_names, ~, task_groundtruth ] = ReadGroundTruth([dataset_folder 'groundtruth_' task '.csv']);
    %% check for incongruency
    task_gt = [];
    for i=1:numel(tools)
        tool = tools{i};
        if numel(tool.tool_scores.ptool_median_scores) ~= size(tool.ptools,1)
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
    best_ptool_scores(best_ptool_scores==0) = 0.9;
    [accuracy_best,accuracy_categs,metric_1] = PlotTestResults( best_ptool_scores, best_ptool_categ_scores, task_gt, tool_names  );
end