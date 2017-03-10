function [ pcl_scale, pcl, A ] = calculatePCLSegScale( pcl, scale_slicing )
    if ~exist('scale_slicing','var')
        scale_slicing = 1;
    end
    slice_prop = .02;
    mean_pcl = mean(pcl);
    pcl = bsxfun(@minus,pcl,mean_pcl);
    [A,~] = pca(pcl);
    pcl = pcl*A;
    
    diff_ranges_threshold = -1;
    if scale_slicing
        pcl = GetMedianRangeBySlicingPcl( pcl, 1, 2, slice_prop, diff_ranges_threshold );
    end
    pcl_scale = range(pcl);
    
    % revert pcl back to its original rotation and position
    pcl = pcl/A;
    pcl = bsxfun(@plus,pcl,mean_pcl);
end

