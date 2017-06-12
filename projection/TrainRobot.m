function [ gpr, sigmaMs, feat_imps, dims_imps, new_ptools, train_res] = TrainRobot( ptools, scores ) 
    sigmaMs = {};
    feat_imps = {};
    dims_imps = {};
    train_res = {};
    found_more_imp_dims = 1;
    orig_num_dims = size(ptools,2);
    prev_dims_imp = 1:25;
    while found_more_imp_dims
        [ gpr, train_res{end+1}.loss_regression, train_res{end+1}.mean_error, train_res{end+1}.ixs_train, train_res{end+1}.ixs_test ] = FitGPR( ptools, scores, 0.05, 1);        
        [ sigmaMs{end+1},  feat_imps{end+1}, new_ptools, dims_imps{end+1}] = PLotGPRLengthScales( gpr, ptools, prev_dims_imp );
        found_more_imp_dims = size(dims_imps{end},2) < size(ptools,2);
        ptools = new_ptools;
        prev_dims_imp = dims_imps{end};
    end
    new_ptools = ptools;
end