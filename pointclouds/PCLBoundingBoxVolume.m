function [ vol, bound_box, pcl_ranges ] = PCLBoundingBoxVolume( pcl )
    min_pcl = min(pcl);
    max_pcl = max(pcl);    
    diff = max_pcl-min_pcl;
    if numel(diff) < 3
        vol = 0;
        bound_box = [0 0 0];
        pcl_ranges = [0 0 0];
        return;
    end
    vol = diff(1)*diff(2)*diff(3);
    bound_box = max_pcl - min_pcl;
    
    pcl_ranges = zeros(1,3);
    for i=1:3
        pcl_ranges(i) = range(pcl(:,i))/2;
    end
    
end

