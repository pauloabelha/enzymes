%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
% based on http://uk.mathworks.com/help/stats/fitrgp.html
%
%% Fit a Gaussian process to the (X,Y) data
% Inputs:
%   X - N * k matrix of N samples from a k-dimensional space
%   Y - N * 1 matrix with the labels for each x
%   perc_test: percentage of the data to use as test data [0,1[
%   plot_fit: boolean whether to plot the results
%       only plots if k is <= 2 (since humans cannot see in 4+ dims)
% Outputs:
%   gpr - a Matlab Gaussian process regression (GPR) model object
%   loss_regression - regression loss on the test data (resubstitution loss)
%       if perc_test = 0, loss_regression will be returned as NaN
%   ixs_train - indexes of training data
%   ixs_test - indexes of test data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ gpr, loss_regression, mean_error, ixs_train, ixs_test ] = FitGPR( X, Y, perc_test, verbose, plot_fit )
    %% sanity checks for X and Y dimensions
    CheckNumericArraySize(X,[Inf Inf]);
    CheckNumericArraySize(Y,[Inf 1]);
    %% set percentage of test data to 0 if unspecified
    if~exist('perc_test','var')
        perc_test = 0;
    end
    CheckScalarInRange( perc_test, 'open-closed', [0 1] );
    %% set not verbose if unspecified
    if~exist('verbose','var') 
        verbose = 1;
    end
    if verbose ~= 0 && verbose ~= 1
        error('Fourth param ''verbose'' should be either 0 or 1');
    end
    %% set not to plot if unspecified
    if~exist('plot_fit','var') 
        plot_fit = 0;
    end   
    if plot_fit ~= 0 && plot_fit ~= 1
        error('Fifth param ''plot_fit'' should be either 0 or 1');
    end
    %% randomly separate the data into training and testing
    ixs = randperm(size(Y,1));
    ixs_test = zeros(size(X,1),1);
    ixs_test(ixs(1:floor(size(ixs,2)*perc_test))) = 1;
    ixs_train = ~ixs_test;
    ixs_test = ~ixs_train;
    X_train = X(ixs_train,:);
    Y_train = Y(ixs_train,:);
    X_test = X(ixs_test,:);
    Y_test = Y(ixs_test,:);
    %% fit a GPR
    gpr = fitrgp(X_train,Y_train,'PredictMethod','exact','KernelFunction','ardsquaredexponential','FitMethod','exact','verbose',verbose);
    %% calculate regression loss
    loss_regression = loss(gpr,X_test,Y_test);
    %% calculate mean error (not mean squared error)
    Y_pred = gpr.predict(X_test);
    mean_error = sum(abs(Y_test-Y_pred))/size(Y_test,1);
    %% plot the results
    if plot_fit
        PLotGPRLengthScales( gpr );
    end
    if plot_fit && size(X,2) <= 2
        figure;
        % when k = 1
        if size(X,2) == 1
            scatter(X_train,Y_train,100,'.k');
            hold on;
            scatter(X_test,Y_test,100,'b');
            legend('Training','Test','Location','bestoutside');
            X_pred_range = min(X)*0.95:var(X)/10:max(X)*1.05;
            [Y_pred,Y_sd] = gpr.predict(X_pred_range');
            shadedErrorBar(X_pred_range',Y_pred,Y_sd,'-k',1); 
            xlabel('Data');
            ylabel('Label');            
        end
        % when k = 2
        if size(X,2) == 2            
            scatter3(X_train(:,1),X_train(:,2),Y_train,100,'.k');
            hold on;
            scatter3(X_test(:,1),X_test(:,2),Y_test,100,'b');
            legend('Training','Test','Location','bestoutside');
            d = 100;
            surf_range_1 = linspace(min(X(:,1))*0.95,max(X(:,1))*1.05,d);
            surf_range_2 = linspace(min(X(:,2))*0.95,max(X(:,2))*1.05,d);
            [X_range1, X_range2] = meshgrid(surf_range_1,surf_range_2);
            [Y_pred,~] = gpr.predict([X_range1(:) X_range2(:)]);
            surf(X_range1,X_range2,reshape(Y_pred,size(X_range1,1),size(X_range2,1)));
        end        
    end
end