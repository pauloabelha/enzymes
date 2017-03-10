%sort eh pcl points according to their distance from the origin
function [ pcl_sorted, sorted_values ] = SortPclDistOrig( pcl )
    zeros_mtx = zeros(size(pcl,1),3);
    idx_dist_orig = sqrt((pcl(:,1).^2-zeros_mtx(:,1).^2)+(pcl(:,2).^2-zeros_mtx(:,2).^2)+(pcl(:,3).^2-zeros_mtx(:,1).^3));
    [sorted_values,idxs_sort_dist_orig] = sort(idx_dist_orig);
    pcl_sorted = pcl(idxs_sort_dist_orig,:);
end

