function [ results ] = PlotResultsTestingVAS( root_folder, results_folder )
    results = load([root_folder 'results/' results_folder 'results.mat']);
    load([root_folder 'results/' results_folder 'results.mat']);
    accuracy_best = -1;
    if sum(best_categ_scores) ~= 0
        accuracy_best = size(best_categ_scores(abs(best_categ_scores-categ_scores_gt)==0),2)/size(best_categ_scores,2);
    end    
       
    non_error_ixs = mode_categ_scores~=0;
    metric_1 = sum(4-abs(best_categ_scores(non_error_ixs)-categ_scores_gt(non_error_ixs)))/size(best_categ_scores(non_error_ixs),2);
    GetRandomRatings( categ_scores_gt(non_error_ixs), 4, 1e6, metric_1 );
    
    figure;
    plot(categ_scores_gt); hold on; plot(best_categ_scores); 
    ax = gca;
    ax.XTickLabel = pcl_filenames;
    ax.XTickLabelRotation = 90;
    ax.XTick = 1:size(pcl_filenames,2);  
    legend('Ground Truth',['Best pTool: ' num2str(ceil(accuracy_best*100)) ' %']);
    figure;
    plot(best_categ_scores);
    ax = gca;
    ax.XTickLabel = pcl_filenames;
    ax.XTickLabelRotation = 90;
    ax.XTick = 1:size(pcl_filenames,2); 
    legend('Raw best Scores');
    title('Best scores (real raw value)');
end

