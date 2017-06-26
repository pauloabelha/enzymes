% By Paulo Abelha
%
% Get the `local' density of a pcl
function [ local_dens, min_dists1, prob_dens, prob_dens_bins ] = PCLLocalDensity( pcl, expect_dens, plot_fig )
    %% check whether to plot
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    if isstruct(pcl)
        pcl = pcl.v;
    end
    if size(pcl,1) > 3e3
        error('Cannot calculate density because it will take too much memory');
    end
    D = pdist2(pcl,pcl);
    diagonal = logical(eye(size(D)));
    D(diagonal) = Inf;
    min_dists1 = min(D,[],1);
    local_dens = mean(min_dists1);
    % get local density as max probability bin
    [prob_dens, prob_dens_bins] = GetProbDistExpResults(min_dists1,expect_dens/100,-1,-1,plot_fig);
%     local_dens = sum(prob_dens(prob_dens_bins<=expect_dens));
end

