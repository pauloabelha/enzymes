function [ final_rank_values, lambda_o_initial,lambda_o_final,lambda_lowers,lambda_uppers ] ...
                        = SortRanksSQ2( ranks, lambda_o_initial,lambda_o_final,lambda_lowers,lambda_uppers )
    %sort voting ranks    
    [~,sorted_ranks_ixs] = SortRank(ranks,'descend');    
    %sort V
    [~,sorted_rank_V_ixs] = sort(sorted_ranks_ixs);
    %sort lambdas according to V
    if isempty(lambda_lowers) || isempty(lambda_uppers)
        [lambda_o_initial,lambda_o_final] = ...
            sortLambdasByV2(sorted_rank_V_ixs,lambda_o_initial,lambda_o_final);
    else
        [lambda_o_initial,lambda_o_final,lambda_lowers,lambda_uppers] = ...
            sortLambdasByV(sorted_rank_V_ixs,lambda_o_initial,lambda_o_final,lambda_lowers,lambda_uppers);
    end
    %sort M, I and S according to the sorting in the sum rank V
    final_rank_values = ranks(sorted_rank_V_ixs);
end

