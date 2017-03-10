function [ rank ] = SortByDensity(pcl_seg, lambda_res, gamma )
    %calculate and accumulate voting ranks        
    %calculate volume of SQ an dpcl
    Vol_SQ = VolumeSQ(lambda_res);        
    [~, Vol_pcl] = convhull(pcl_seg(:,1), pcl_seg(:,2), pcl_seg(:,3));
    %calculate I and S                 
    Fx_rank_voting = RecoveryFunctionSQ2(lambda_res, pcl_seg);
    I = length(Fx_rank_voting(Fx_rank_voting<(1-gamma)));
    S = Fx_rank_voting((1-gamma) <= Fx_rank_voting);
    S = S(S < (1+gamma));
    S = length(S);
    SQ_density = (I+S)/Vol_SQ;
    pcl_density = size(pcl_seg,1)/Vol_pcl;
    rank = pdist([SQ_density;pcl_density],'euclidean');
end

