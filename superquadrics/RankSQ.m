function [ F, E, E_pcl_SQ, E_SQ_pcl  ] = RankSQ(pcl,SQ)
    % if pcl is too big downsample because of RAM memory issues
    MAX_POINTS = 1e4;
    if size(pcl,1) > MAX_POINTS
        warning(['Pcl size (' num2str(size(pcl,1)) ' points) too big. Downsampling pcl to ' num2str(MAX_POINTS) ' points before calculating']);
        pcl = pcl(randi(size(pcl,1),MAX_POINTS,1),:);
    end
    %calculate F
    if size(SQ,2) == 16
       F = SQToroidFunction( SQ, pcl );
    else
        F = SQFunctionNormalised( SQ, pcl, [] );        
    end    
    F = sum(abs(F))/size(pcl,1);
    % calculate mse
    P = SQ2PCL(SQ,size(pcl,1));
    SQ_pcl = P.v;
    [E, E_pcl_SQ, E_SQ_pcl] = PCLDist( pcl, SQ_pcl );
end

