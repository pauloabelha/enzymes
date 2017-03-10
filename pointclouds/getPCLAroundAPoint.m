% get a point cloud where every point is a point inside the sphere with
% with the center seed_point and radius seed_radius
function pcl_out = getPCLAroundAPoint(pcl,seed_point,seed_radius,min_n_points)
    if length(pcl) < min_n_points
        error('The length of the pcl is less than the minimum number of points.');
    end
    epsilon = 0.01;
    pcl_out = [];
    %increase seed_radius until pcl_out has at least MIN_PCL_LENGTH points
    while length(pcl_out) < min_n_points
        pcl_out=[];
        %get every point within seed_radius
        dist_pcl = sqrt(((pcl(:,1)-seed_point(1)).^2)+((pcl(:,2)-seed_point(2)).^2)+((pcl(:,3)-seed_point(3)).^2)); 
        pcl_out = pcl(seed_radius-epsilon<=dist_pcl<=seed_radius+epsilon,:);
        seed_radius = seed_radius*2;
    end
end