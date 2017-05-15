function [ pcl ] = RemovePCLRangePeaks( pcl )
    MAX_PEAK = 1e3;
    n_to_cut = 3;
    [pcl_slices, pcl_slice_ranges] = SlicePointCloud(pcl,1,0.005);
    diff_rangesY = abs(diff(pcl_slice_ranges(:,2)))/median(abs(diff(pcl_slice_ranges(:,2))));
    diff_rangesZ = abs(diff(pcl_slice_ranges(:,3)))/median(abs(diff(pcl_slice_ranges(:,3))));
    ix_start = 0;
    ix_end = numel(pcl_slices)+1;
    for i=1:n_to_cut
        if diff_rangesY(i) > MAX_PEAK || diff_rangesZ(i) > MAX_PEAK
            ix_start = ix_start + 1;
        end        
        if diff_rangesY(end-(i-1)) > MAX_PEAK || diff_rangesZ(end-(i-1)) > MAX_PEAK
            ix_end = ix_end - 1;
        end
    end
    slices = pcl_slices(ix_start+1:ix_end-1);
    pcl = concatcellarrayofmatrices( slices, 1 );
end

