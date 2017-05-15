% By Paulo Abelha
%
% Get the density of a pcl
function [ d ] = PCLDensity( pcl, plot_fig )
    %% check whether to plot
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    if isstruct(pcl)
        pcl = pcl.v;
    end
    if size(pcl,1) > 2e3
        error('Cannot calculate density because it will take too much memory');
    end
    D = pdist2(pcl,pcl);
    diagonal = logical(eye(size(D)));
    D(diagonal) = Inf;
    min_dists1 = min(D,[],1);
    d = mean(min_dists1);
    if plot_fig
        histogram(min_dists1);
    end
end

