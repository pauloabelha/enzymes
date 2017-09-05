function [ best_ptool_scores, best_ptool_ixs, tool_names ] = GetCalibrationForPTools( dataset_folder, task, training_filepath, extracted_ptool_filepath )
    load(training_filepath);
    load(extracted_ptool_filepath);
    best_ptool_scores = zeros(1,size(ptools,2));
    best_ptool_ixs = best_ptool_scores;
    ix = 0;
    for i=1:size(ptools,2)
        best_score = -Inf;
        best_ix = 0;
        for j=1:size(ptools{i},1)
            ix = ix + 1;            
            if Y(ix) > best_score
                best_score = Y(ix);  
                best_ix = j;
            end
        end
        best_ptool_scores(i) = best_score;
        best_ptool_ixs(i) = best_ix;
    end    
    %% read task groundtruth
    [ tool_names, ~, task_groundtruth ] = ReadGroundTruth([dataset_folder 'groundtruth_' task '.csv']);
    %% find best param triad
    start = min(best_ptool_scores);
    step = range(best_ptool_scores)/100;
    finish = max(best_ptool_scores);
%     [ best_params, best_score, B_best ] = FindBestParamTriad( start, step, finish, task_groundtruth, best_ptool_scores' );
    best_ptool_categ_scores = TaskCategorisation(best_ptool_scores,task);
    [accuracy_best,accuracy_categs,metric_1] = PlotTestResults( best_ptool_scores, best_ptool_categ_scores, task_groundtruth', tool_names  );
end

