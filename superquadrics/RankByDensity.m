function [ rank ] = RankByDensity(pcl_seg, lambda_res, gamma1, gamma2 )
    pcl_density=800000;   
    %calculate expec_n_points_SQ
    Vol_SQ = VolumeSQ(lambda_res);  
    expec_n_points_SQ = round(pcl_density*Vol_SQ);
    %calculate actual_n_points_SQ
    Fx_rank_voting = RecoveryFunctionSQ2(lambda_res, pcl_seg);
    I = length(Fx_rank_voting(Fx_rank_voting<(1-gamma1)));
    %I_vec(i) = stdNormalDist(length(rank_voting_pcl),I_vec(i),5)/0.3989;
    S = Fx_rank_voting(Fx_rank_voting >= (1-gamma1));
    S = S(S < gamma2);
    S = length(S);
    actual_n_points_SQ = I+S;
    rank = actual_n_points_SQ/expec_n_points_SQ;
end

