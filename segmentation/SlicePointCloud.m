function [slices, ranges] = SlicePointCloud(pcl,dim,slice_size)
    % min number of points per slice
    MIN_N_POINTS_PER_SLICE = 10;    
    % the first slice begins at the leftmost of the pcl
    beg_slice = min(pcl(:,dim)) - eps;    
    % get the limit of the pcl
    limit_slice = max(pcl(:,dim));
    %% slice the pcl until the limit is reached
    slices = {};
    ranges = [];
    while beg_slice < limit_slice
        end_slice = beg_slice + slice_size;
        ixs_slice = pcl(:,dim)>beg_slice & pcl(:,dim)<=end_slice;
        slices{end+1} = pcl(ixs_slice,:);
        if size(slices{end},1) < MIN_N_POINTS_PER_SLICE
            ranges(end+1,:) = [0 0 0 ];
        else
            slice_range = range(slices{end});
            ranges(end+1,:) = slice_range;
        end
        beg_slice = end_slice;
    end
end