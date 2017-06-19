%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% By Paulo Abelha (p.abelha@abdn.ac.uk)
% based on: http://uk.mathworks.com/help/stats/tune-gaussian-mixture-models.html
%
% This function will fit and choose the best Gaussian Mixture Model
% Inputs:
%   X - N * M matrix of N samples form an M-dimensional space
%   k_guess - first guess at k. If provided, the function tries ks
%       in the range k_guess+-50% i.e. with a k_guess of 5, the function
%       will try ks from 3-7. If not provided, the function tries ks from
%       1 to 10
%   plot: whether to plot or not up to the first 3 dimensions.
%       Default is not to plot 
% Outputs:
%   gmms - k * c * t cell array with all tried Gaussian mixture Models
%       k is number of components tried
%       c is number of covariances tried
%       t is number of type of covariances tried
%   best_ixs - 3-elem array with the indexes of the best model
%   
%   The function works by trying out different models and picking the one
%   with the lowest estimated AIC and BIC
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ gmBest, gmBest_AIC, gmBest_BIC ] = FitAndChooseGaussianMixtureModel( X, plot_fit, k_guess, n_tryouts, dim_plot )
    % Number of EM iterations to perform
    N_EM_ITER = 10000;
    % number of tryouts (outer for loops trying the fitting multiple times)
    if ~exist('n_tryouts','var')
        n_tryouts = 1;
    end
    N_TRYOUTS = max(n_tryouts,1);
    % set plot to 0 if not defined
    if ~exist('plot_fit','var')
        plot_fit=0;
    end
    % if k_guess was not defined, try a range of different k
    max_k = 10;
    if ~exist('k_guess','var')
        k = 1:max_k;
    % else, either try a range of different k if k_guess is 0 or else 
    % a range of ks: k_guess +- 50%
    else
        if k_guess == 0
            k = 1:max_k;
        else
            % range of ks to try
            if k_guess <0
                error('Please specify a k_guess larger (or equal) to 0');
            end
            k = ceil(k_guess/2):floor(3*k_guess/2); 
        end
    end
    % get which dimensions to plot
    if ~exist('dim_plot','var') || size(dim_plot,1) < 2
        dim_plot = [1 2];        
    end    
    % number of ks to try
    nK = numel(k);
    % covariance matrices to tryy
    Sigma = {'diagonal','full'};
    % number of covariance matrices to try
    nSigma = numel(Sigma);
    % covariance matrix sharings to try 
    SharedCovariance = {true,false};
    SCtext = {'true','false'};
    % number of covariance matrix sharings to try
    nSC = numel(SharedCovariance);
    % include regularization to avoid badly conditioned covariance matrices
    RegularizationValue = 0.01;
    % increase the number of EM tries to 10000
    options = statset('MaxIter',N_EM_ITER);
    % preallocation of variables
    gmms = cell(nK,nSigma,nSC);
    aic = zeros(nK,nSigma,nSC);
    bic = zeros(nK,nSigma,nSC);
    converged = false(nK,nSigma,nSC);
    min_sum_aic_bic = Inf;
    % try all models a number N_TRYOUTS of times  
    ixs_best_AIC = [0 0 0 0];
    min_AIC = Inf;
    ixs_best_BIC = [0 0 0 0];
    min_BIC = Inf;
    init_iter = 1;
    tot_iter = nSC*nSigma*nK*N_TRYOUTS;
    tot_toc = 0;
    iter=0;
    for m = 1:nSC
        for j = 1:nSigma
            for i = 1:nK
                for t=1:N_TRYOUTS 
                    tic
                    iter = iter + 1;
                    % fit the current model
                    gmms{i,j,m,t} = fitgmdist(X,k(i),...
                        'CovarianceType',Sigma{j},...
                        'SharedCovariance',SharedCovariance{m},...
                        'RegularizationValue',RegularizationValue,...
                        'Options',options);
                    % calculate AIC and BIC as measures of fitness
                    aic(i,j,m,t) = gmms{i,j,m,t}.AIC;
                    bic(i,j,m,t) = gmms{i,j,m,t}.BIC;
                    sum_aic_bic = aic(i,j,m,t)+bic(i,j,m,t);
                    % store the current best model's indexes
                    if aic(i,j,m,t) < min_AIC
                        min_AIC=aic(i,j,m,t);
                        ixs_best_AIC = [i j m t];
                    end
                    if bic(i,j,m,t) < min_BIC
                        min_BIC=bic(i,j,m,t);
                        ixs_best_BIC = [i j m t];
                    end
                    if sum_aic_bic < min_sum_aic_bic
                        min_sum_aic_bic=sum_aic_bic;
                        ixs_best_gmm = [i j m t];
                    end
                    % store the convergence for each model
                    converged(i,j,m,t) = gmms{i,j,m,t}.Converged;
                    tot_toc = DisplayEstimatedTimeOfLoop( tot_toc+toc, iter, tot_iter-init_iter );
                end
            end
        end
    end
    % check if all instances converged
    allConverge = (sum(converged(:)) == nK*nSigma*nSC);
    if ~allConverge
       warning('Fitting iterations did not converge'); 
    end
    % get best gmm
    gmBest_AIC = gmms{ixs_best_AIC(1),ixs_best_AIC(2),ixs_best_AIC(3),ixs_best_AIC(4)};
    gmBest_BIC = gmms{ixs_best_BIC(1),ixs_best_BIC(2),ixs_best_BIC(3),ixs_best_BIC(4)};
    gmBest = gmBest_AIC;
    % get number of components
    kGMM = gmBest.NumComponents;
    % plot the fitted gaussians up to the first 3 dimensions
    if plot_fit        
        % deal with the number of dimensions of X       
        if size(X,2) == 1
            % plot the data histogram
            figure('Name','Data histogram');
            histogram(X);     hold on; 
            %hold off;
            % plot the inferred Gaussian(s)
            %figure('Name','Inferred Gaussians');
            for i=1:kGMM     
                sigma_ix = min(size(gmBest.Sigma,2),i);
                sigma_over_100 = max(1e-5,gmBest.Sigma(sigma_ix)/1000);
                X_range = min(X):sigma_over_100:max(X);
                plot(X_range,normpdf(X_range,gmBest.mu(i),gmBest.Sigma(sigma_ix)));                
            end            
            hold off;        
            % plot the inferred histogram
            figure('Name','Inferred histogram');
            histogram(gmBest.random(size(X,1)));      
            title(['nSC: ' num2str(ixs_best_AIC(1)), ', nSigma: ' num2str(ixs_best_AIC(2)),...
                ', nK: ' num2str(ixs_best_AIC(3)), ', nSC: ' num2str(ixs_best_AIC(4))]);
            hold off;
        else  
            if size(X,2) == 2
                % get a list containing the cluster for each point
                % assignment works by choosing the cluster tht maximizes the
                % posterior
                clusterX = cluster(gmBest,X);
                % effective number of components: required for when the cluster 
                % function did not assign any point to one or more clusters
                % this can happen due to numerical instability of very small 
                % posteriors (and/or two clusters having the same posterior)
                effective_kGMM = size(unique(clusterX),1);
                % if there are points whose posterior is too small to have been 
                % assigned a cluster, post a warning for the user
                if effective_kGMM ~= kGMM
                    warning('Number of assigned clusters is not the same as k for the best model. Assignment works by choosing the cluster with maximum posterior for that point. Some points may contain a very small (or equal) posterior leading to unstable assignment.'); 
                end        
                min_range=2; max_range=2;
                d = 500;
                x1 = linspace(min(X(:,dim_plot(1)))*min_range,max(X(:,dim_plot(1)))*max_range,d);
                x2 = linspace(min(X(:,dim_plot(2)))*min_range,max(X(:,dim_plot(2)))*max_range,d);            
                [x1grid,x2grid] = meshgrid(x1,x2);
                X0 = [x1grid(:) x2grid(:)];
                % get the Mahalonobis distance and threshold for the confidence interval 
                mahalDist = mahal(gmBest,X0);
                %mahalDist = bsxfun(@rdivide,mahal(gmBest,X0),gmBest.Sigma);
                threshold = sqrt(chi2inv(0.99,2));           
                % plot the points, colouring them by cluster
                figure('Name','Clustered Data and Component Structures');
                xlabel('Dim 1');
                ylabel('Dim 2');                
                h1 = gscatter(X(:,dim_plot(1)),X(:,dim_plot(2)),clusterX);                
                cluster_legend = {};
                hold on;
                % for each cluster, plot the points around the mean that are inside the confidence interval   
                for j = 1:effective_kGMM;  
                    % get the indexes of points inside the confidence interval
                    idx = mahalDist(:,j)<=threshold;
                    % give the condifence interval a dim version of the cluster's colour
                    Color = h1(j).Color*0.9 + -0.9*(h1(j).Color - 1);
                    % plot the confidence interval
                    h2 = plot(X0(idx,1),X0(idx,2),'.','Color',Color,'MarkerSize',1);
                    uistack(h2,'bottom');
                    % plot the legend for the cluster
                    cluster_legend{end+1} = ['Cluster ' num2str(j)];
                end
                % plot an X at each mean of the clusters
                plot(gmBest.mu(:,1),gmBest.mu(:,2),'kx','LineWidth',2,'MarkerSize',10);
                legend(h1,cluster_legend,'Location','NorthEast');
                % free figure window     
                axis equal;
                hold off
                X2= gmBest.random(size(X,1));
                figure; scatter(abs(X2(:,1)),abs(X2(:,2)),10,'.k'); axis equal;
            end
        end
    end
end

