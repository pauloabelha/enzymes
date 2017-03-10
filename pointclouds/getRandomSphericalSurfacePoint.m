function point = getRandomSphericalSurfacePoint(pcl,center,radius)
    epsilon = 0.01;
    pcl_out=[];
    while isempty(pcl_out)        
        dist_pcl = sqrt(((pcl(:,1)-center(1)).^2)+((pcl(:,2)-center(2)).^2)+((pcl(:,3)-center(3)).^2)); 
        pcl_out = pcl(radius-epsilon<=dist_pcl,:);
        dist_pcl = sqrt(((pcl_out(:,1)-center(1)).^2)+((pcl_out(:,2)-center(2)).^2)+((pcl_out(:,3)-center(3)).^2)); 
        pcl_out = pcl_out(dist_pcl<=radius+epsilon,:);       
        epsilon = epsilon*2;       
    end 
    point = pcl_out(randsample(size(pcl_out,1),1),:); 
end