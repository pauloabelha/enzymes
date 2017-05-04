function [SQ,F,E,E_pcl_SQ, E_SQ_pcl ] = FitSQtoPCL_normal(pcl,pcl_scale,ix,opt_options,fitting_modes,fit_constraints)
    SQ = zeros(15,1); F = Inf; E = Inf; E_PROP = Inf; E_pcl_SQ = Inf; E_SQ_pcl = Inf;
    MIN_PCL_SCALE = 1e-7;
    if fitting_modes(1) == 1
        if isempty(fit_constraints)            
            if pcl_scale(1)/pcl_scale(2) > pcl_scale(2)/pcl_scale(3)
                z_scale = pcl_scale(1);
                pcl_scale(1) = pcl_scale(3);
                pcl_scale(3) = z_scale;
            end    
            if min(pcl_scale) < MIN_PCL_SCALE
                error(['SQ FItting: Normal. Point cloud has one or more dimensions that are too small: ' num2str(pcl_scale)]);            
            end
            pcl_scale = pcl_scale./2;
            min_scale = pcl_scale*0.95;
            initial_scale = pcl_scale;
            max_scale = pcl_scale*1.05;
            min_pos = min(pcl);
            [~,initial_pos] = kmeans(pcl,1);
            max_pos = max(pcl);
        else
            min_scale = fit_constraints.min_scale;
            initial_scale = fit_constraints.initial_scale;
            max_scale = fit_constraints.max_scale;
            min_pos = fit_constraints.min_pos;
            initial_pos = fit_constraints.initial_pos;
            max_pos = fit_constraints.max_pos;
        end
        for i=1:3
            min_scale(i) = max(min_scale(i),0.0005);
        end
        lower_lambda = [min_scale 0.1 0.1 0 0 0 0 0 0 0 min_pos];
        initial_angles = [pi/randsample(1:2,1) pi/randsample(1:2,1) pi/randsample(1:2,1)];
        initial_lambda = [initial_scale 0.1 1 initial_angles 0 0 0 0 initial_pos]; 
        upper_lambda = [max_scale 2 2 pi pi pi 0 0 0 0 max_pos];
        [SQ,~,~,~,~] = lsqnonlin(@(x) SQFunctionNormalised(x, pcl), initial_lambda, lower_lambda,upper_lambda, opt_options);
        [ F, E, E_pcl_SQ, E_SQ_pcl  ] = RankSQ(pcl, SQ );
    end
end