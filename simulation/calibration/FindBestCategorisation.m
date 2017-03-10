% search through the 3 (thanks, Sev) parameters defining the boundaries for categorising
% into the 3 categories and pick the best one (the one that gives out the
% best score in a given dataset)
function [ best_params, best_score, B_best ] = FindBestCategorisation( dataset_folder, calib_res_folder, task )
    %[ tool_scores, task, ~, ~, best_ptool_scores, best_ptools_ixs_ ] = ReadCalibrationResults( output_filepath );
    [ tool_scores, ~, ~, ~, best_ptool_scores ] = ReadClusterCalibrationResults(calib_res_folder, task );
    tools = MergeCalibrationResultsPtoolData( task, tool_scores, dataset_folder, 'ptools_training.mat');
    %% check for incongruency
    for i=1:numel(tools)
        tool = tools{i};
        if numel(tool.tool_scores.ptool_median_scores) ~= size(tool.ptools,1)
            warning(['Tool ' tool.name ' has a different number of ptools than the original extracted one.']);
        end
    end
    %% get groundtruth for existing tools
    [tools_gt, tool_names] = GetToolsGT(dataset_folder, task, tools);    
    if size(best_ptool_scores,1) ~= size(tools_gt,1)
        error('Groundtruth vector and real-valued vector have different sizes');
    end
    %% search through the 3 params
    best_ptool_scores(best_ptool_scores==0) = min(best_ptool_scores(best_ptool_scores>0));
    start = min(best_ptool_scores);
    step = range(best_ptool_scores)/100;
    finish = max(best_ptool_scores);
    [ best_params, best_score, B_best ] = FindBestParamTriad( start, step, finish, tools_gt', best_ptool_scores' );
end