% search through the 3 (thanks, Sev) parameters defining the boundaries for categorising
% into the 3 categories and pick the best one (the one that gives out the
% best score in a given dataset)
function [ best_params, best_score, B_best ] = FindBestCategorisation( dataset_folder, calib_res_file )
    load([dataset_folder calib_res_file]);
    %% check for incongruency
    for i=1:numel(tools)
        tool = tools{i};
        if numel(tool.ptool_median_scores) ~= size(tool.ptools,1)
            warning(['Tool ' tool.name ' has a different number of ptools than the original extracted one.']);
        end
    end
    %% get groundtruth for existing tools
    [ ~, ~, task_groundtruth ] = ReadGroundTruth([dataset_folder 'groundtruth_' task '.csv']);  
    %% search through the 3 params
%     best_ptool_scores(best_ptool_scores==0) = min(best_ptool_scores(best_ptool_scores>0));
    best_ptool_scores(best_ptool_scores>50) = 0;
    start = min(best_ptool_scores);
    step = range(best_ptool_scores)/100;
    finish = max(best_ptool_scores);
    [ best_params, best_score, B_best ] = FindBestParamTriad( start, step, finish, task_groundtruth, best_ptool_scores' );
end