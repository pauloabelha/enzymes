function  [accuracy_best,accuracy_categs,metric_1,metric_2,p,mu,sigma] = PlotTestResults( best_scores, best_categ_scores, pcl_gt_task_scores, pcl_filenames, dont_get_rand_ratings  )
    if ~exist('dont_get_rand_ratings','var')
        dont_get_rand_ratings = 0;
    end
    if ~exist('plot_log','var')
        plot_log = 0;
    end
    if ischar(best_scores)
        filename = best_scores;
        load(filename);
        disp(['File loaded: ' filename]);
    end

    best_categ_scores(isnan(pcl_gt_task_scores)) = -1;
    pcl_gt_task_scores(isnan(pcl_gt_task_scores)) = -1;


    if sum(best_categ_scores) ~= 0
        accuracy_best = size(best_categ_scores(abs(best_categ_scores-pcl_gt_task_scores)==0),2)/size(best_categ_scores,2);
    else
        accuracy_best = -1;
    end 
    
    accuracy_categs = zeros(1,4);
    for i=1:4
        if size(best_categ_scores(pcl_gt_task_scores == i),2) ~= 0            
            accuracy_categs(i) = size(best_categ_scores(best_categ_scores == i & pcl_gt_task_scores == i),2)/size(best_categ_scores(pcl_gt_task_scores == i),2);
        end
    end
    metric_2 = sum(accuracy_categs);
       
    non_error_ixs = best_categ_scores~=0;
    %metric_1 = sum(4-abs(best_categ_scores(non_error_ixs)-pcl_gt_task_scores(non_error_ixs)))/size(best_categ_scores(non_error_ixs),2);
    metric_1 = Metric1(best_categ_scores,pcl_gt_task_scores);
    metric_1 = round(metric_1,2);
    if ~dont_get_rand_ratings
        [~, ~, p, mu, sigma] = GetRandomRatings( pcl_gt_task_scores(non_error_ixs), 4, 1e5, metric_1, {'Metric 1'}, 'Random Ratings' );
    else
        p=0; mu=0; sigma=0;
    end
    
    figure;
    plot(pcl_gt_task_scores); hold on;
    plot(best_categ_scores); 
    plot(pcl_gt_task_scores-best_categ_scores); 
    ax = gca;
    ax.XTickLabel = pcl_filenames;
    ax.XTickLabelRotation = 90;
    ax.XTick = 1:size(pcl_filenames,2);      
    ax.YLim = [-4 5];
    legend('Ground Truth',['Best pTool: ' num2str(ceil(accuracy_best*100)) ' %'],'GT - Best p-tool');
    figure;
    if plot_log
        plot(log(best_scores));
    else
        plot(best_scores);
    end
    ax = gca;
    ax.XTickLabel = pcl_filenames;
    ax.XTickLabelRotation = 90;
    ax.XTick = 1:size(pcl_filenames,2); 
    legend('Raw best Scores');
    title('Best scores (real raw value)');
    figure;
    plot(accuracy_categs);
    title('Accuracy per category');

end

