function [ pcl_out ] = PCLSurfaceSQ( pcl, SQ, gamma1, gamma2 )
    F = RecoveryFunctionSQ2(SQ, pcl);       
    ixs_greater_than_or_equal = F >= (1-gamma1);
    ixs_smaller_than = F < gamma2;
    ixs = ixs_greater_than_or_equal & ixs_smaller_than;    
    pcl_out = pcl(ixs,:);
end
