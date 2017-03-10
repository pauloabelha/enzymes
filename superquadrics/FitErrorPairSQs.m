function [ E, E1, E2, I1, I2  ] = FitErrorPairSQs( SQ1, SQ2 )
    downsample = 5000;
    SQ1_pcl = UniformSQSampling3D(SQ1,0,downsample);
    SQ2_pcl = UniformSQSampling3D(SQ2,0,downsample);
    [ E, ~, E1, E2  ] = FitErrorBtwPointClouds( SQ1_pcl,SQ2_pcl );
    if size(SQ1,2) == 16
       F1 = SQToroidFunction( SQ1, SQ2_pcl );
    else
        [F1,F1_SQ] = SQFunctionNormalised( SQ1, SQ2_pcl, [] );        
    end
    I1 = size(F1_SQ(F1_SQ<=1),1)/size(F1_SQ,1);
    if size(SQ2,2) == 16
       F2 = SQToroidFunction( SQ2, SQ1_pcl );
    else
        [F2,F2_SQ] = SQFunctionNormalised( SQ2, SQ1_pcl, [] );        
    end
    I2 = size(F2_SQ(F2_SQ<=1),1)/size(F2_SQ,1);
end

