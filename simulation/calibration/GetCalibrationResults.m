function [ tool_names, best_ptool_scores, best_ptool_categ_scores, tools_gt, tool_scores, tools, accuracy_best,accuracy_categs,metric_1, task, best_ptools_ixs ] = GetCalibrationResults( dataset_folder, output_filepath, tool_scores, task, best_ptool_scores, tools )    
    if ~exist('tool_scores','var') && ~exist('task','var') && ~exist('best_ptool_scores','var')
        [ tool_scores, task, ~, ~, best_ptool_scores, best_ptools_ixs_ ] = ReadCalibrationResults( output_filepath );
    end
    if ~exist('tools','var')
        tools = MergeCalibrationResultsPtoolData( task, tool_scores, dataset_folder, 'extracted_ptools.mat');
    end
    %% check for incongruency
    for i=1:numel(tools)
        tool = tools{i};
        if numel(tool.tool_scores.ptool_median_scores) ~= size(tool.ptools,1)
            warning(['Tool ' tool.name ' has a different number of ptools than the original extracted one.']);
        end
    end
    %% get groundtruth for existing tools
    [tools_gt, tool_names] = GetToolsGT(dataset_folder, task, tools);
    best_ptool_categ_scores = TaskCategorisation(best_ptool_scores,task);
    best_ptool_scores(best_ptool_scores==0) = 0.9;
    [accuracy_best,accuracy_categs,metric_1] = PlotTestResults( best_ptool_scores, best_ptool_categ_scores, tools_gt, tool_names  );
end