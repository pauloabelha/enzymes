function [ final_MIS_values, SQs ] ...
                        = FinalSortRanksSQ( M_vec, I_vec, S_vec, Sc_vec, SQs )
    [V, rank_V] = calculateV_and_rank_V(M_vec,I_vec,S_vec,Sc_vec);
    %sort V
    [~,sorted_rank_V_ixs] = sort(rank_V);
    %sort lambdas according to V
    [~,SQs] = sortLambdasByV2(sorted_rank_V_ixs,SQs,SQs);
    %sort M, I and S according to the sorting in the sum rank V
    final_MIS_values= [rank_V' M_vec' I_vec' S_vec' Sc_vec' V'];
    %final_MIS_values = final_MIS_values(sorted_rank_V_ixs,:);
end


