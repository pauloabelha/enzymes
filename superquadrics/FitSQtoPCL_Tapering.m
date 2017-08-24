function [SQ,F,E,E_pcl_SQ, E_SQ_pcl ] = FitSQtoPCL_Tapering(pcl,pcl_scale,ix,opt_options,fitting_modes,fit_constraints,initial_lambda_in)
    SQ = zeros(15,1); F = Inf; E = Inf; E_PROP = Inf; E_pcl_SQ = Inf; E_SQ_pcl = Inf;
    MIN_PCL_SCALE = 1e-7;
    if fitting_modes(2) == 1
        if exist('initial_lambda_in','var')
            x = initial_lambda_in;
        else
            mean_pcl = mean(pcl);
            pcl = pcl - mean_pcl;
            pca_pcl = pca(pcl);
            pcl = pcl*pca_pcl;
            pcl_scale = range(pcl)/2;
            MIN_PROP_SCALE_FOR_3D = 0.05;
            [sorted_scale,sorted_scale_ixs] = sort(pcl_scale);
            if sorted_scale(1)/sorted_scale(2) < MIN_PROP_SCALE_FOR_3D || sorted_scale(1)/sorted_scale(3) < MIN_PROP_SCALE_FOR_3D
                a=0;
            end
            z = pcl_scale(3);
            pcl_scale(3) = pcl_scale(1);
            pcl_scale(1) = z;
            pcl_scale(1:2) = sort(pcl_scale(1:2));
            if min(pcl_scale) < MIN_PCL_SCALE
                error(['SQ FItting: Tapering. Point cloud has one or more dimensions that are too small: ' num2str(pcl_scale)]);
            end
            [~,centroid] = kmeans(pcl,1);
            x = [pcl_scale 0.1 1 -pi -pi/2 0 0 0 0.001 0 centroid]; 
        end
        initial_lambda = x;
        initial_lambda(9:10) = -1;
        lower_lambda = [initial_lambda(1:3)*0.85 0.1 0.1 initial_lambda(6:8) -1 -1 0 0 centroid];
        upper_lambda = [initial_lambda(1:3)*1.15 2 2 initial_lambda(6:8) 1 1 0 0 centroid];
        [SQ,~,~,~,~] = lsqnonlin(@(x) SQFunctionNormalised(x, pcl), initial_lambda, lower_lambda,upper_lambda, opt_options);
        [F,E,E_pcl_SQ, E_SQ_pcl ] = RankSQ(pcl, SQ );
        SQ(end-2:end) = SQ(end-2:end) + mean_pcl;
        SQ = RotateSQWithRotMtx(SQ,inv(pca_pcl));
    end
end