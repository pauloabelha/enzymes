function [sorted_rank_v,sorted_rank] = SortRank(rank,mode)
    if strcmp(mode,'descend')
        [sorted_rank_v,sorted_M_ixs] = sort(rank,'descend');
    else
        [sorted_rank_v,sorted_M_ixs] = sort(rank);
    end
    prev = sorted_rank_v(1);
    rank_n=1;
    for i=1:length(rank)
        if ~(sorted_rank_v(i) == prev)
            rank_n=rank_n+1;
        end
        sorted_rank(sorted_M_ixs(i)) = rank_n;
    end
end

