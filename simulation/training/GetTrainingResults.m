function [ accuracy_best, accuracy_categs, metric_1, metric_2, p,mu,sigma ] = GetTrainingResults( dataset_folder, task )    
    sampled_ptools = [];
    ptool_median_scores = [];
    task_ = task;
    load([dataset_folder 'ptools_training.mat']);
    task = task_;
    load([dataset_folder task '_training_data.mat']);
    task = task_;
    gpr_scores = gpr.predict(sampled_ptools(ixs_training,8:end));
    gpr_categ_scores = TaskCategorisation(gpr_scores,task);
    ptool_categ_scores = TaskCategorisation(ptool_median_scores,task);
    [accuracy_best,accuracy_categs,metric_1,metric_2,p,mu,sigma] = PlotTestResults( gpr_scores', gpr_categ_scores', ptool_categ_scores, pcl_filenames, 0 );
end


