function [ gprs, sigmaMs, feat_imps, dims_ixs, train_res ] = RobotTrain( ptools, scores, root_folder, task, suffix ) 
    if ~exist('task','var') || ~exist('root_folder','var')
        warning('No task or root folder defined. File is going to be save at home with task unkown');
        root_folder = '~/';
        task = 'unkown';
    end
    if ~exist('suffix','var')
        suffix = '';
    end
    gprs = {};
    sigmaMs = {};
    feat_imps = {};    
    train_res = {};
    prev_n_dims = Inf;
    n_dims = 25;
    dims_ixs = {logical(ones(1,n_dims))};
    curr_n_dims = size(ptools,2);
    while curr_n_dims < prev_n_dims 
        disp([curr_n_dims curr_n_dims]);
        prev_n_dims = curr_n_dims;
        [ gprs{end+1}, train_res{end+1}.loss_regression, train_res{end+1}.mean_train_error, train_res{end+1}.mean_test_error, train_res{end+1}.ixs_train, train_res{end+1}.ixs_test ] = FitGPR( ptools(:,dims_ixs{end}), scores, 0.25, 1);        
        [ sigmaMs{end+1}, feat_imps{end+1}, last_dim_ixs ] = PLotGPRLengthScales( gprs{end}, ptools(:,dims_ixs{end}), 0 );        
        dims_ixs{end+1} = dims_ixs{end};
        dims_ixs{end}(dims_ixs{end}==1) = last_dim_ixs;
        curr_n_dims = sum(dims_ixs{end});
        save([root_folder 'trained_robot_' task '_' date suffix]);
    end
end