function [ rank ] = SortRanks(sorting_mode, pcl, SQ, gamma)
    if strcmp(sorting_mode,'segmenting')
        rank = SortScoreBySegmenting(pcl, SQ );
    elseif strcmp(sorting_mode,'density')
        rank = SortByDensity(pcl, SQ, gamma );
end

