function [ gprs, sigmaMs, feat_imps, dims_ixs ] = TrainRobot( ptools, scores ) 
    gprs = {};
    sigmaMs = {};
    feat_imps = {};    
    train_res = {};
    prev_n_dims = Inf;
    n_dims = 25;
    dims_ixs = {logical(ones(1,n_dims))};
    curr_n_dims = size(ptools,2);
    while curr_n_dims < prev_n_dims  
        prev_n_dims = curr_n_dims;
        [ gprs{end+1}, train_res{end+1}.loss_regression, train_res{end+1}.mean_error, train_res{end+1}.ixs_train, train_res{end+1}.ixs_test ] = FitGPR( ptools(:,dims_ixs{end}), scores, 0.05, 1);        
        [ sigmaMs{end+1}, feat_imps{end+1}, last_dim_ixs ] = PLotGPRLengthScales( gprs{end}, ptools(:,dims_ixs{end}), 0 );        
        dims_ixs{end+1} = dims_ixs{end};
        dims_ixs{end}(dims_ixs{end}==1) = last_dim_ixs;
        curr_n_dims = sum(dims_ixs{end});
    end
end