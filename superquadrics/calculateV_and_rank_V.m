function [V, rank_V,M_vec] = calculateV_and_rank_V( M_vec,I_vec,S_vec,Sc_vec)
    %sort voting ranks    
    [~,sorted_M_ixs] = SortRank(M_vec,'ascend');    
    [~,sorted_I_ixs] = SortRank(I_vec,'ascend');
    [~,sorted_S_ixs] = SortRank(S_vec,'descend');
    [~,sorted_Sc_ixs] = SortRank(Sc_vec,'ascend');    
    %calculate final ranking V
    V = [I_vec; S_vec];
    rank_V = sorted_M_ixs+sorted_I_ixs+sorted_S_ixs+sorted_Sc_ixs;
end

