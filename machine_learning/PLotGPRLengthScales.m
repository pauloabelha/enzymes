function [ sigmaM, feat_imp, new_data, dims_imp] = PLotGPRLengthScales( gpr, data )
    d = size(gpr.ActiveSetVectors,2);
    sigmaM = gpr.KernelInformation.KernelParameters(1:end-1,1);
    feat_imp = [];
    new_data = [];
    if exist('data','var')
        % get feature importance
        feat_imp = range(data)' ./ sigmaM;
        log_feat_imp = log(feat_imp);
        % get data from important features only
        dims_imp = 1:numel(log_feat_imp);
        dims_imp = dims_imp(log_feat_imp>-2);
        new_data = data(:,log_feat_imp>-2);
        plot((1:d)',log_feat_imp,'ro-');
        ylabel('Log of feature importance (range / lengthscale)');
    else  
        plot((1:d)',log(sigmaM),'ro-');
        xlabel('Length scale number');
        ylabel('Log of length scale');
    end
    hold off;
end

