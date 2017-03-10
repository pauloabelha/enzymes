function [ isPatchy, patchy_prop, F, E, E_pcl_SQ, E_SQ_pcl ] = IsPatchyPCL( pcl, SQ )
    isPatchy = 0;
    if ~exist('SQ','var')
        SQ = PCL2SQ( pcl, 2, 1, 0, [1 0 0 0 0] );
        SQ = SQ{1};
    end
    [ F, E, E_pcl_SQ, E_SQ_pcl ] = RankSQ(pcl,SQ);
    patchy_prop = E_pcl_SQ/E_SQ_pcl;
    
end

