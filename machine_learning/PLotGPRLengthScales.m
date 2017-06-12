function [ sigmaM, feat_imp, new_data, dims_imp] = PLotGPRLengthScales( gpr, data, dims_imp, plot_fig )
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    MIN_IMP = -1;
    d = size(gpr.ActiveSetVectors,2);
    sigmaM = gpr.KernelInformation.KernelParameters(1:end-1,1);
    feat_imp = [];
    new_data = [];
    if exist('data','var')
        % get feature importance
        feat_imp = range(data)' ./ sigmaM;
        log_feat_imp = log(feat_imp);
        % get data from important features only
        if exist('dims_imp','var') && isempty(dims_imp)
            dims_imp = 1:size(data,2);
        end
        dims_imp = dims_imp(log_feat_imp>=MIN_IMP);
        new_data = data(:,log_feat_imp>=MIN_IMP);
        if plot_fig
            plot((1:d)',log_feat_imp,'ro-');
            ylabel('Log of feature importance (range / lengthscale)');
        end
    else  
        if plot_fig
            plot((1:d)',log(sigmaM),'ro-');
            xlabel('Length scale number');
            ylabel('Log of length scale');
        end
    end
    if plot_fig
        hold off;
    end
end

