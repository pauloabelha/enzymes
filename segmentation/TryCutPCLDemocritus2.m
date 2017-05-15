function segms = TryCutPCLDemocritus2( pcl, slice_size, run_pca, plot_fig )
    if ~exist('run_pca','var')
        run_pca = 0;
    end
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    if run_pca
        pca_pcl = pca(pcl);
        pcl_pca = pcl*pca_pcl;
    else
        pca_pcl = eye(3);
        pcl_pca = pcl;
    end
    [pcls, ~, cut_belief] = CutPCLDemocritus2( pcl_pca, slice_size, 1 );
    segms = pcls;
    max_cut_belief = cut_belief;
    for i=2:2
        [pcls, ~, cut_belief] = CutPCLDemocritus2( pcl_pca, slice_size, i );  
        if cut_belief > max_cut_belief && ( (numel(pcls) <= numel(segms)) || (numel(segms) == 1 && numel(pcls) > 1) )
            max_cut_belief = cut_belief;
            segms = pcls;
        end
    end
    if isempty(segms)
        segms = {segms};
    end
    if run_pca
        for i=1:numel(segms)
            segms{i} = segms{i}*inv(pca_pcl);
        end
    end
    if plot_fig
        PlotPCLS(segms);
    end
end
