function [ X_trains, Y_trains, Y_train_preds, X_tests, Y_tests, Y_test_preds, train_errors, test_errors, train_error, test_error, test_error_std ] = RobotPlotTrain( filepath, ixs_test_fixed, X, Y, plot_fig )
    if ~exist('plot','var')
        plot_fig = 1;
    end
    if ~exist('ixs_test_fixed','var')
        ixs_test_fixed = [];
    end 
    load(filepath);
    n_options = numel(train_res);
    X_trains = cell(1,n_options);
    Y_trains = cell(1,n_options);
    Y_train_preds = cell(1,n_options);
    X_tests = cell(1,n_options);
    Y_tests = cell(1,n_options);
    Y_test_preds = cell(1,n_options);
    test_error_stds = zeros(n_options,1);
    train_errors = zeros(n_options,sum(train_res{1}.ixs_train));    
    if isempty(ixs_test_fixed)
        test_errors = zeros(n_options,sum(train_res{1}.ixs_test));
    else
        test_errors = zeros(n_options,numel(ixs_test_fixed));
    end
    for i=1:n_options
        X_trains{i} = ptools(train_res{i}.ixs_train,dims_ixs{i});
        Y_trains{i} = scores(train_res{i}.ixs_train); 
        Y_train_preds{i} = gprs{i}.predict(X_trains{i});
        train_errors(i,:) = abs(Y_trains{i}-Y_train_preds{i});        
        if isempty(ixs_test_fixed)
            X_tests{i} = ptools(train_res{i}.ixs_test,dims_ixs{i});
            Y_tests{i} = scores(train_res{i}.ixs_test); 
        else
            X_tests{i} = X(ixs_test_fixed,dims_ixs{i});
            Y_tests{i} = Y(ixs_test_fixed);
        end
        [Y_test_preds{i},test_error_stds_] = gprs{i}.predict(X_tests{i});
        test_error_stds(i) = mean(test_error_stds_);
        test_errors(i,:) = abs(Y_tests{i}-Y_test_preds{i});
    end
    train_error = mean(abs(Y_train_preds{end}-Y_trains{end}));
    test_error = mean(abs(Y_test_preds{end}-Y_tests{end}));
    test_error_std = test_error_stds(end);
    if plot_fig
        figure; title('Training errors');
        plot(sum(train_errors,2)/size(train_errors,2));
        figure; title('Test errors');
        plot(sum(test_errors,2)/size(test_errors,2))
    end
end

