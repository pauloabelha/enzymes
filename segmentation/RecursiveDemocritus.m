function [ segms ] = RecursiveDemocritus( pcl, slice_size, plot_fig )
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    pca_pcl = pca(pcl);
    pcl = pcl*pca_pcl;
    [ segms, stack ] = RecursiveDemocritus_recursive( pcl, slice_size, [], {} );
    if ~isempty(stack)
        segms{end+1} = stack;
    end
    for i=1:numel(segms)
        segms{i} = segms{i}/pca_pcl;
    end
    if plot_fig
        PlotPCLS(segms);
    end
end


function [ segms_accum, stack ] = RecursiveDemocritus_recursive( pcl, slice_size, stack, segms_accum )
    segms = CutPCLDemocritus2( pcl, slice_size, 1 );
    PlotPCLS(segms);
    close all;    
    if numel(segms) == 1
        if isempty(stack)
            stack = segms{1};
            return;
        end
        % merge stack with current segm
        merged = [stack; pcl];     
        segms_of_merged = CutPCLDemocritus2( merged, slice_size, 1 );
        if numel(segms_of_merged) == 1
            stack = merged;
        else
            segms_accum{end+1} = stack;
            stack = pcl;
        end
        return;
    end
    for i=1:numel(segms)
        [ segms_accum, stack ] = RecursiveDemocritus_recursive( segms{i}, slice_size, stack, segms_accum );
    end
end

