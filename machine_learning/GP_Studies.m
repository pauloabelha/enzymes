% gaussian processes studies

% get data
% load('medians_input.dat'); 
% load('medians_output.dat');      
% X = medians_input;
% Y = medians_output;
X = dlmread('~/enzymes_data/sampled_ptools.txt');
X = [X(:,17) X(:,18)];
dim_plot = [1 2];
Y = dlmread('~/.gazebo/gazebo_models/hammering_training/medians_output.dat');
% Y = Y(1:100);

% percentage of test set
perc_test = 0;
%percentage of training set
per_train = 1 - perc_test;
%resolution to plot the surface of a 2-dim function
d = 500;
surf_range_1 = linspace(min(X(:,dim_plot(1)))*0.95,max(X(:,dim_plot(1)))*1.05,d);
surf_range_2 = linspace(min(X(:,dim_plot(2)))*0.95,max(X(:,dim_plot(2)))*1.05,d);
surf_range = 0:0.1:9;

% kernel function
% kfcn = @(XN,XM,theta) (exp(theta(2))^2)*exp(-(pdist2(XN,XM).^2)/(2*exp(theta(1))^2));
% theta0 = [0.6564,0.0034];

% get training and test indexes
ixs = randperm(size(Y,1));
ixs_test = ixs(1:size(ixs,2)*perc_test);
ixs_train = ixs(size(ixs_test,2)+1:end);
% get traning data
X_train = X(ixs_train,:);
Y_train = Y(ixs_train,:);
[~,X_train_sorted_ixs] = sort(X_train);
% get test data
X_test = X(ixs_test,:);
Y_test = Y(ixs_test,:);
[~,X_test_sorted_ixs] = sort(X_test);
% fit a gaussian process
gprMdl = fitrgp(X_train,Y_train);

[X_range1, X_range2] = meshgrid(surf_range_1,surf_range_2);
X_range = [reshape(X_range1,size(X_range1,1)^2,1) reshape(X_range2,size(X_range2,1)^2,1)];
[Y_pred_range,~,Y_95_confid] = predict(gprMdl,X_range);

% compute the loss regression
L = loss(gprMdl,X_test,Y_test);
% plot train and test data
figure; hold on;
if size(X_train,2) > 1
    scatter3(X_train(:,1),X_train(:,2),Y_train,100,'.b');
else
    scatter(X_train(X_train_sorted_ixs),Y_train(X_train_sorted_ixs),100,'.b');
end
hold on;
if size(X_test,2) > 1
    scatter3(X_test(:,1),X_test(:,2),Y_test,100,'.g');
else
    scatter(X_test,Y_test,100,'.g');
end
hold on;
% plot confidence shaded regions of 1 std
if size(X,2) > 1
    Y_surf = reshape(Y_pred_range,sqrt(size(X_range(:,1),1)),sqrt(size(X_range(:,2),1)));
    hold on; surf(surf_range_1,surf_range_2,Y_surf,'CDataMapping','scaled');
%     scatter3(X_range(:,1),X_range(:,2),Y_95_confid(:,1),100,'.c');
%     scatter3(X_range(:,1),X_range(:,2),Y_95_confid(:,2),100,'.c');
else
    shadedErrorBar(X_range,Y_pred_range,Y_sd_range,'-k',1); 
end
% put labels on the graph
xlabel('Dim 1');
ylabel('Dim 2');
legend({'training','confidence intervals','Gaussian Process Fit'},'Location','Best');
title(strcat('Hammering Nail: Regression Loss = ',num2str(L)));
hold off






% %code based on Max-Planck Phillip Hennig Youtube lessons
% 
% % prior on W
% F = 2;                                                                      % number of features
% phi = @(a)bsxfun(@power,a,0:F-1);                                           % phi(a) = [1;a]
% mu = zeros(F,1);                                    
% Sigma = eye(F);                                                             % p(w) = N(p,E)
% 
% % prior on f(x)
% n = 100; x = linspace(-6,6,n)';                                             % 'test' points
% phix = phi(x);                                                              % features of x
% m = phix * mu;                                      
% kxx = phix * Sigma * phix';                                                 % p(fx) = N(m,kxx)
% s = bsxfun(@plus,m,chol(kxx + 1.0e-8 * eye(n))' * randn(n,3));              % samples form prior
% stdpi = sqrt(diag(kxx));                                                    % marginal stddev, for plotting
% 
% %prior on Y = f_X + eps
% phiX = phi(X);                                                              % features of data
% M = phiX * mu;
% kXX = phiX * Sigma * phiX';                                                 % p(f_X) = N(M,kXX)
% 
% G = kXX + sigma^2 * eye(N);                                                 % p(Y) = N(M,kXX + sigma^2 * I)
% R = chol(G);                                                                 % most expensive step: O(n^3)
% 
% kxX = phix * Sigma * phiX';                                                 % conv(f_x,f_X) = kxX;
% A = kxX / R;                                                                % pre-compute for re-use
% 
% mpost = m + A * (R' \ (Y-M));                                               % p(f_x|Y) = N(m+kxX*(kXX+sigma^2*I)'*(Y-M),
% vpost = kxx - A * A';                                                       %               kxx - kxX*(kXX+sigma^2*I)'*kXx)   
% spost = bsxfun(@plus,mpost,chol(vpost + 1.0e-8 * eye(n))' * randn(n,3));     % samples
% 
% stdpo = sqrt(diag(vpost));                                                  % marginal stddev, for plotting
% 
% 
% 
% 
% 
% 
