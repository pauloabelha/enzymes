function [accs, metrics1] = ReadProjectionAblation(filepath)
    load(filepath);
    n_weights = size(weights,1);
    accs = zeros(n_weights,1);
    metrics1 = accs;
    for weight_ix=1:n_weights
        best_categ_scores = best_categ_scores_mtx(:,weight_ix);
        accs(weight_ix) = size(best_categ_scores(abs(best_categ_scores-tools_gt)==0),1)/size(best_categ_scores,1);
        metrics1(weight_ix) = Metric1(best_categ_scores',tools_gt',4);
    end
end