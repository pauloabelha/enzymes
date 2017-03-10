function [mmd, std_md, thresh, perc_above_tresh, min_dist_pcl] = GetMeanMinDistPCL(pcl1, pow_punish, pcl2)
    if ~exist('pow_punish','var')
        pow_punish = 1;
    end
    if ~exist('pcl2','var') || isempty(pcl2)
        pcl2 = pcl1;
    end
    N_STDS_FOR_THRESHOLD = 2;
    D = pdist2(pcl1, pcl2).^pow_punish;
    D(D<1e-5) = Inf;
    min_dist_pcl = min(D,[],1);
    mmd = mean(min_dist_pcl);
    std_md = std(min_dist_pcl);
    thresh = mmd+N_STDS_FOR_THRESHOLD*std_md;
    perc_above_tresh = size(min_dist_pcl(min_dist_pcl>thresh),2)/size(min_dist_pcl,2);
end