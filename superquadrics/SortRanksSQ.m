function [ final_MIS_values, lambda_o_initial,lambda_o_final,lambda_lowers,lambda_uppers ] ...
                        = SortRanksSQ( M_vec, I_vec, S_vec, Sc_vec, lambda_o_initial,lambda_o_final,lambda_lowers,lambda_uppers )
    [V, rank_V] = calculateV_and_rank_V(M_vec,I_vec,S_vec,Sc_vec);
    %sort V
    [~,sorted_rank_V_ixs] = sort(rank_V);
    %sort lambdas according to V
    if isempty(lambda_lowers) || isempty(lambda_uppers)
        [lambda_o_initial,lambda_o_final] = ...
            sortLambdasByV2(sorted_rank_V_ixs,lambda_o_initial,lambda_o_final);
    else
        [lambda_o_initial,lambda_o_final,lambda_lowers,lambda_uppers] = ...
            sortLambdasByV(sorted_rank_V_ixs,lambda_o_initial,lambda_o_final,lambda_lowers,lambda_uppers);
    end
    %sort M, I and S according to the sorting in the sum rank V
    final_MIS_values = [M_vec' I_vec' S_vec' Sc_vec' rank_V' V'];
    final_MIS_values = final_MIS_values(sorted_rank_V_ixs,:);
end

