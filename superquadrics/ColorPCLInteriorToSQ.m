function [ coloured_pcl ] = ColorPCLInteriorToSQ( pcl, SQ, gamma, colour )
    F = RecoveryFunctionSQ2(SQ, pcl);
    %calculate I and S                 
    coloured_pcl = pcl(pcl<(1-gamma),:);
    %I_vec(i) = stdNormalDist(length(rank_voting_pcl),I_vec(i),5)/0.3989;
    S = F((1-gamma) <= F);
    S = S(S < (1+gamma));


end

