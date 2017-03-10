function [ pcl_out ] = PCLInteriorToSQ( pcl, SQ, gamma1 )
    F = RecoveryFunctionSQ2(SQ, pcl);            
    pcl_out = pcl(F<(1-gamma1),:);
end

