function [ sigmaM, feat_imp, imp_dims_ixs, imp_dims_sort_ixs, new_data ] = PLotGPRLengthScales( gpr, data, plot_fig )
    %% check whether not to plot
    if ~exist('plot_fig','var')
        plot_fig = 1;
    end
    %% first param must exist with the gpr
    if ~exist('gpr','var')
        error('Please provide a trained gpr as first param');
    end
    %% if data does not exist, use the gpr's active vectors
    if ~exist('data','var')
        data = gpr.ActiveSetVectors;
    end
    % minimum importance
    MIN_IMP = 0;
    %% get entropy for each column
    % minimum entropy in log 2 to consider the data column
    MIN_ENTROPY_DATA = 0.1;    
    data_entr_cols = zeros(1,size(data,2));
    for i=1:size(data,2)
        data_entr_cols(i) = EntropyExpResults( data(:,i)', 10 );
    end
    range_data = range(data)';
    d = size(gpr.ActiveSetVectors,2);
    sigmaM = gpr.KernelInformation.KernelParameters(1:end-1,1);
    feat_imp = range_data ./ sigmaM;
    
    log_feat_imp = log(feat_imp)';
    imp_dims_ixs = log_feat_imp >= MIN_IMP & data_entr_cols >= MIN_ENTROPY_DATA;
    [~, imp_dims_sort_ixs] = sort(log_feat_imp,'descend');
    new_data = data(:,imp_dims_ixs);
    if plot_fig
        %% plot data range per dimension
        figure;
        plot((1:d)', range_data,'ro-');
        title('Data range per dimension');
        xlabel('Dimension');
        ylabel('Range');
        hold off;
        %% plot kernel lengthscale per dimension
        figure;
        plot((1:d)',log(sigmaM),'ro-');
        title('Kernel length scale per dimension');
        xlabel('Length scale number');
        ylabel('Log of length scale');
        hold off;
        %% plot feature importance    
        figure;
        plot((1:d)',log_feat_imp,'ro-');
        title('Log importance per dimension');
        ylabel('Log of feature importance (range / lengthscale)');
        hold off;
        %% plot data entropy per dimension
        figure;
        plot((1:d)',data_entr_cols,'ro-');
        title('Data entropy per dimension');
        xlabel('Dimension');
        ylabel('Entropy (log 10)');
        hold off;
    end
end

