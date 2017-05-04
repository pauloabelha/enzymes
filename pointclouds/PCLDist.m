function [ E, E1, E2, penalty_far_points, A, min_dists_both ] = PCLDist( pcl1,pcl2 )
    % punishment for being far (using quadratic)
    pow_punish = 1;
    % if size of pcls are different, downsample the largest one
    if size(pcl2,1) > size(pcl1,1)        
        pcl2 = pcl2(randsample(1:size(pcl2,1),size(pcl1,1)),:);        
    elseif size(pcl1,1) > size(pcl2,1) 
       %pcl1 = pcl1(randsample(1:size(pcl1,1),size(pcl2,1)),:);        
    end    
    % get number of points
    N_PTS = size(pcl1,1);
    % get dist (punishing - here power 1) between point pairs from each pcl
    DIST=pdist2(pcl1,pcl2).^pow_punish;
    % get min dist between each point from pcl1 and its closest in pcl2
    min_dists1 = min(DIST,[],1);
    % get probability of a point from pcl1 being `close' to one from pcl2
    [~, ~, TRESH_2STD1] = GetMeanMinDistPCL(pcl1, pow_punish);
    %TRESH_2STD1 = 0.005;
    E1 = size(min_dists1(min_dists1>TRESH_2STD1),2)/N_PTS;
    % get min dist between each point from pcl2 and its closest in pcl1
    min_dists2 = min(DIST,[],2);
    % get probability of a point from pcl2 being `close' to one from pcl1    
    [~, ~, TRESH_2STD2] = GetMeanMinDistPCL(pcl2, pow_punish);
    %TRESH_2STD2 = 0.005;
    E2 = size(min_dists2(min_dists2>TRESH_2STD2),1)/N_PTS;
    % get min dist between point pairs form each pcl
    min_dists_both = [min_dists1'; min_dists2];
    % get probability of a point pair from each pcl being `close'
    TRESH_2STD = (TRESH_2STD1 + TRESH_2STD2)/2;
    E = size(min_dists_both(min_dists_both>TRESH_2STD & min_dists_both>0.002),1)/(2*N_PTS);
    penalty_far_points = size(min_dists_both(min_dists_both>0.02),1)/size(min_dists_both(min_dists_both>TRESH_2STD),1);
    A = sum(min_dists_both(min_dists_both>0.025));
    E = E + A;    
end