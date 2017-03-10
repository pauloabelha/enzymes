function [SQ,F,E,E_PROP,E_pcl_SQ,E_SQ_pcl] = FitSQtoPCL_Toroid(pcl,pcl_scale,ix,opt_options,initial_lambda_in,fitting_modes)  
    SQ = zeros(15,1); F = Inf; E = Inf; E_PROP = Inf; E_pcl_SQ = Inf; E_SQ_pcl = Inf; 
    MIN_PCL_SCALE = 0.0001;
    if fitting_modes(4) == 1
        if nargin > 3               
            initial_lambda = [initial_lambda_in(1:3) .05 initial_lambda_in(4:end)];
            lower_lambda = [initial_lambda(1:3) .01 initial_lambda(5:end)];
            upper_lambda = [initial_lambda(1:3) .1 initial_lambda(5:end)];
        else
            if pcl_scale(1)/pcl_scale(2) > pcl_scale(2)/pcl_scale(3)
                z_scale = pcl_scale(1);
                pcl_scale(1) = pcl_scale(3);
                pcl_scale(3) = z_scale;
            end    
            if min(pcl_scale) < MIN_PCL_SCALE
                error(['Point cloud has one or more dimensions that are too small: ' num2str(pcl_scale)]);
            end
            [~,centroid] = kmeans(pcl,1);
            lower_lambda = [pcl_scale.*0.8 0.1 0.1 0.1 0 0 0 0 0 0 0 min(pcl)];
            initial_lambda = [pcl_scale 0.2 0.1 1  pi/ix pi/ix pi/ix 0 0 1 0 centroid]; 
            upper_lambda = [pcl_scale 1 2 2 2*pi 2*pi 2*pi 0 0 0 0 max(pcl)];
        end    
        [SQ,~,~,~,~] = lsqnonlin(@(x) SQToroidFunction(x, pcl), initial_lambda, lower_lambda,upper_lambda, opt_options);    
        [F,E,E_PROP,E_pcl_SQ, E_SQ_pcl ] = RankSQ(pcl, SQ );
    end
end