function [ P ] = CentralisePCL( P )
    mean_pcl = mean(P.v);
    P.v = P.v - mean(P.v);
    for i=1:numel(P.segms)
        P.segms{i}.v = P.segms{i}.v - mean_pcl;
    end
end

