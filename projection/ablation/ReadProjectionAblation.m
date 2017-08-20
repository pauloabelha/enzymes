function [accs, accuracy_categs, metrics1] = ReadProjectionAblation(filepath, task)
    load(filepath);
    n_weights = size(weights,1);
    accs = zeros(n_weights,1);
    metrics1 = accs;
    accuracy_categs = zeros(n_weights,4);
    for weight_ix=1:n_weights
        best_scores = best_scores_mtx(:,weight_ix);
        best_categ_scores = TaskCategorisation(best_scores,task);
        accs(weight_ix) = size(best_categ_scores(abs(best_categ_scores-tools_gt)==0),1)/size(best_categ_scores,1);
        metrics1(weight_ix) = Metric1(best_categ_scores',tools_gt',4);
        % accuracy per categ        
        for i=1:4
            if size(best_categ_scores(tools_gt == i),1) ~= 0            
                accuracy_categs(weight_ix,i) = size(best_categ_scores(best_categ_scores == i & tools_gt == i),1)/size(tools_gt(tools_gt == i),1);
            end
        end
    end
end