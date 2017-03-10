function [ rank ] = SortScoreBySegmenting(pcl, SQ_params )
    [~, pcl_out1, pcl_out2] = splitPclFromSQ(pcl,SQ_params);
    rank = (length(pcl_out1)+length(pcl_out2))/length(pcl);
    rank = 1/rank;
end

