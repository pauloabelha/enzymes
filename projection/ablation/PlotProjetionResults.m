function [accuracy_best,accuracy_categs,metric_1,metric_2,p,mu,sigma] = PlotProjetionResults( test_folder, filepath )
    load(filepath);
    [ tool_names, ~, tools_gt_categ ] = ReadGroundTruth([test_folder 'groundtruth_' task '.csv']);
    [accuracy_best,accuracy_categs,metric_1,metric_2,p,mu,sigma] = PlotTestResults( scores, TaskCategorisation(scores,task), tools_gt_categ', tool_names);
end

