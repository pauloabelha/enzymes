function seeds = getSeedPointsCodelet(pcl,seeds_center,seeds_radius,n_seeds)
    if seeds_radius < 0 || size(seeds_center,2) == 1
        seeds_ixs = randsample(size(pcl,1),min(size(pcl,1),n_seeds));
        seeds = pcl(seeds_ixs,:);
    else
        epsilon = 0.001;
        seeds = [];
        while isempty(seeds)
            euclid_dist = [pcl sqrt((pcl(:,1)-seeds_center(1)).^2+(pcl(:,2)-seeds_center(2)).^2+(pcl(:,3)-seeds_center(3)).^2)];
            euclid_dist = euclid_dist(euclid_dist(:,4)<=seeds_radius+epsilon,:);
            seeds_ixs = randsample(1:size(euclid_dist,1),min(size(euclid_dist,1),n_seeds));
            seeds = euclid_dist(seeds_ixs,1:3);
            epsilon = epsilon*2;
        end
    end
end

