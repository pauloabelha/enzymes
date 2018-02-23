function [ E, E1, E2 ] = PCLDist( pcl1,pcl2 )
    % if size of pcls are different, downsample the largest one
    if size(pcl2,1) > size(pcl1,1)        
        pcl2 = pcl2(randsample(1:size(pcl2,1),size(pcl1,1)),:);        
    elseif size(pcl1,1) > size(pcl2,1) 
        pcl1 = pcl1(randsample(1:size(pcl1,1),size(pcl2,1)),:);        
    end    
    % get errors
    E1 = get_error(pcl1, pcl2);
    E2 = get_error(pcl2, pcl1);
    E = (E1 + E2)/2;
end

function E = get_error(pcl1, pcl2, base)
    if ~exist('base','var')
        base = 1.5;
    end
    % get dist (punishing - here power 1) between point pairs from each pcl
    DIST=pdist2(pcl1,pcl2);
    % get min dist between each point from pcl1 and its closest in pcl2
    min_dists = min(DIST,[],1);
    if max(min_dists) > 0.1
        E = Inf;
    else    
        [P_mass, P_bins] = GetProbDistExpResults( min_dists, 0.001, [0 0.1]);
        a=1:numel(P_bins);
        E = sum(P_mass .* base .^ a);
    end
end
