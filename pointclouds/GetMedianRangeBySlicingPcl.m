function [ pcl, diff_ranges_threshold ] = GetMedianRangeBySlicingPcl( pcl, dim1, dim2, slice_prop, diff_ranges_threshold )
    min_prop_dims = 100;
    prop_dims = range(pcl(:,dim2))/range(pcl(:,dim1));
    if prop_dims <= min_prop_dims
        max_pcl_cut_prop = .2;        
        [~,dim1_sorted_ixs] = sort(pcl(:,dim1),'ascend');
        pcl = pcl(dim1_sorted_ixs,:);
        pcl_length=length(pcl);
        slice_length = ceil(size(pcl,1)*slice_prop);
        n_slices = floor(pcl_length/slice_length);
        ranges = zeros(n_slices,1);
        diff_ranges = zeros(n_slices-1,1);
        slice = pcl(1:slice_length,:); 
        ranges(1) = range(slice(:,dim2));
        pcl_min_cut_ix = 1;
        for i=2:n_slices
            ix_begin = (i-1)*slice_length;
            slice = pcl(ix_begin+1:ix_begin+slice_length,:); 
            ranges(i) = range(slice(:,dim2)); 
            diff_ranges(i-1) = abs(ranges(i) - ranges(i-1));
        end
        if diff_ranges_threshold < 0
            min_diff_ranges_threshold = mean(diff_ranges)-2*std(diff_ranges);
            max_diff_ranges_threshold = mean(diff_ranges)+2*std(diff_ranges);
        end
        half_of_diff_ranges =  floor(n_slices/2);
        avg_range_diff = diff_ranges(half_of_diff_ranges);
        for i=1:half_of_diff_ranges
            ix = (half_of_diff_ranges - i)+1;
            if diff_ranges(ix) < min_diff_ranges_threshold || diff_ranges(ix) > max_diff_ranges_threshold
                pcl_min_cut_ix = ix*slice_length;
                break;
            end
            avg_range_diff = (avg_range_diff + diff_ranges(ix))/2;        
        end
        pcl_max_cut_ix = n_slices*slice_length;
        for ix=half_of_diff_ranges+1:n_slices-1
            if diff_ranges(ix) < min_diff_ranges_threshold || diff_ranges(ix) > max_diff_ranges_threshold
                pcl_max_cut_ix = ix*slice_length;
                break;
            end
            avg_range_diff = (avg_range_diff + diff_ranges(ix))/2;        
        end

        if pcl_min_cut_ix <= size(pcl,1)*max_pcl_cut_prop
            pcl = pcl(pcl_min_cut_ix:pcl_max_cut_ix,:);
        end
    end
end
