%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
% based on
%http://uk.mathworks.com/help/stats/gaussian-process-regression-models.html
%
%% Plot a Gaussian process in the selected dimensions
% Inputs:
%   gpr - a Matlab Gaussian process regression (GPR) model object
%       the gpr is k-dimensional
%   X_proj_pt: point in which the k-(1 or 2) dimensions will be kept fixed
%   ranges - a (1 or 2) * n_dims matrix with the ranges
%       in which to predict for the (each) dimension(s)
%   dims - a number > 1 or a 1 * 2 array indicating the dimensions to plot
% Outputs:
%   Y_pred - the predicted values for every data point
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Y_pred = PlotGPR( gpr, X_proj_pt, ranges, dims, axis_ranges )
    %% sanity check for inputs
    if ~isa(gpr,'RegressionGP')
       error('You must input a Gaussian process regression model class'); 
    end
    k = size(gpr.ActiveSetVectors,2);
    if size(dims,1) > 1 || size(dims,2) < 1 || dims(1) < 1
       error('Dimensions input must be a number > 1 or a 1 * 2 array indicating the dimensions to plot'); 
    end    
    for i=1:size(dims,2)
       if dims(i) < 1
           error('Dimensions input cannot contain a number smaller than 1'); 
       end
       if dims(i) > k
           error('Dimensions input cannot contain a number greater than the number k of dimensions'); 
       end
    end
    if size(ranges,1) ~= size(dims,2) || size(ranges,2) ~= 2
        error('Ranges must be a (1 or 2) * 2 array defining the ranges for each dimension'); 
    end
    if size(X_proj_pt,1) ~= 1 || size(X_proj_pt,2) ~= k
        error('Point of projection must be a 1 x k array'); 
    end
    %% prepare figure
    figure;
    hold on;
    dim_1 = dims(1);
    %% plot the gpr in 1 dimension
    if size(dims,2) == 1       
        X_dim1_range = ranges(1)*0.95:(ranges(2)-ranges(1))/10:ranges(2)*1.05;
        X_pred = repmat(X_proj_pt,size(X_dim1_range,2),1);
        X_pred(:,dim_1) = X_dim1_range(:);
        [Y_pred,Y_sd] = gpr.predict(X_pred);
        shadedErrorBar(X_dim1_range,Y_pred,Y_sd,'-k',1); 
        xlabel('Data');
        ylabel('Label');            
    end
    %% plot the gpr in 2 dimensions
    if size(dims,2) == 2
        dim_2 = dims(2);
        d = 50;
        surf_range_1 = linspace(ranges(1,1)*0.95,ranges(1,2)*1.05,d);
        surf_range_2 = linspace(ranges(2,1)*0.95,ranges(2,2)*1.05,d);
        [X_range1, X_range2] = meshgrid(surf_range_1,surf_range_2);
        X_pred = repmat(X_proj_pt,d^2,1);
        X_pred(:,dim_1) = X_range1(:);
        X_pred(:,dim_2) = X_range2(:);
        [Y_pred,~] = gpr.predict(X_pred);
        surf(X_range1,X_range2,reshape(Y_pred,size(X_range1,1),size(X_range2,1)));
        if exist('axis_ranges','var')
            axis(axis_ranges);
        end
    end   
    hold off;
end