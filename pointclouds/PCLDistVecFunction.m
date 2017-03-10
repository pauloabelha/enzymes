function [ F ] = PCLDistVecFunction( SQ, pcl1 )
    % punishment for being far (using quadratic)
    pow_punish = 1;
    % get SQ pcl
    pcl2 = UniformSQSampling3D(SQ,0,size(pcl1,1));
    % if size of pcls are different, downsample the largest one
    if size(pcl2,1) > size(pcl1,1)        
        pcl2 = pcl2(randsample(1:size(pcl2,1),size(pcl1,1)),:);        
    elseif size(pcl1,1) > size(pcl2,1) 
        pcl1 = pcl1(randsample(1:size(pcl1,1),size(pcl2,1)),:);        
    end    
    % get dist (punishing - here quadratically) between point pairs from each pcl
    DIST=pdist2(pcl1,pcl2).^pow_punish;
    % get min dist between each point from pcl1 and its closest in pcl2
    min_dists1 = min(DIST,[],1);
    min_dists2 = min(DIST,[],2);
    F = (min_dists1'+min_dists2)/2;
end

