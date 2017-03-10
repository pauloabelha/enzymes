function [ SQ_patch_ix ] = CheckPatchSegment( SQ_fit1, SQ_fit2, SQ_pcl1, SQ_pcl2  )
    patch_threshold = 2;
    P.v = SQ_pcl1;
    P = DownsamplePCL(P,2000);
    SQ_pcl1 = P.v;
    P.v = SQ_pcl2;
    P = DownsamplePCL(P,2000);
    SQ_pcl2 = P.v;
    [ ~, ~, E1, E2, ~  ] = FitErrorBtwPointClouds( SQ_pcl1, SQ_pcl2 );
    vol_SQ1 = VolumeSQ(SQ_fit1);
    vol_SQ2 = VolumeSQ(SQ_fit2);
    SQ_patch_ix = 0;
    if vol_SQ1 < vol_SQ2
        if E2 < patch_threshold
            SQ_patch_ix = 1;
        end
    else
        if E1 < patch_threshold
            SQ_patch_ix = 2;
        end
    end
end

