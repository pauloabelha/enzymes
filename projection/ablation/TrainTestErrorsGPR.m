function [ train_errors, test_errors ] = TrainTestErrorsGPR( sim_filepath, root_folder, task, date_, N1, N_test )
    load(sim_filepath);        
    ix=0;
    ixs_test_fixed = randsample(size(X,1),N_test);
    N2=0;
    for i=100:50:N1
        N2=N2+1;
    end
    train_errors = zeros(N2,1);
    test_errors=train_errors;
    test_errors_stds=test_errors;
    for i=100:50:N1
        ix=ix+1;
        M=i;
        [~,~,~,~,~,~,~,~,train_errors(ix),test_errors(ix),test_errors_stds(ix)] = RobotPlotTrain( [root_folder 'trained_robot_' task '_' date_ '_' num2str(M) '.mat'], ixs_test_fixed, X, Y, 0 );
        disp(['Completed:' char(9) num2str(round(M/N1,2)*100) ' %']);
    end
    figure; title('Train errors');
    plot(train_errors);
    figure; title('Test errors');
    plot(test_errors);
end

