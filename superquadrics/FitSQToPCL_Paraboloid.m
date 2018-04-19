function [SQ,F,E,E_pcl_SQ, E_SQ_pcl ] = FitSQToPCL_Paraboloid( pcl,pcl_scale,ix,opt_options,fitting_modes,fit_constraints)
    SQ = zeros(1,15); F = Inf; E = Inf; E_pcl_SQ = Inf; E_SQ_pcl = Inf;
    if fitting_modes(5)
        MIN_PROP_SCALE_FOR_3D = 0.05;
        if min(pcl_scale)/max(pcl_scale) < MIN_PROP_SCALE_FOR_3D
            return;
        end
        pcl_scale = pcl_scale/2;
        if ix == 1 || ix == 3
            initial_scale(3) = pcl_scale(1);
            initial_scale(2) = pcl_scale(2);
            initial_scale(1) = pcl_scale(3);
        else
            initial_scale = pcl_scale;           
        end
        initial_scale(3) = initial_scale(3)*0.9;
        initial_epsilon = .1;
        initial_epsilon2 = 1;
        angle_options = {0 pi/2 pi -pi/2};
        initial_angle = [0 angle_options{mod(ix,4)+1} 0];
        initial_lambda = [initial_scale initial_epsilon initial_epsilon2 initial_angle mean(pcl(:,1:3))];
        SQ_init = [initial_lambda(1:8) 0 0 0 -1 initial_lambda(end-2:end)];  
        SQ_P = SQ2PCL(SQ_init,size(pcl,1));
        SQ_pcl = SQ_P.v;
        [E_init, E_pcl_SQ_init, E_SQ_pcl_init ] = PCLDist(pcl,SQ_pcl);
        F_init = sum(SuperParaboloidFunction(SQ_init, pcl))/size(pcl,1);
        min_lambda = [initial_scale*0.9 0.1 0.1 -pi -pi -pi initial_lambda(8:10)];
        max_lambda = [initial_scale*1.05 2 0.5 pi pi pi initial_lambda(8:10)+0.05];        
        SQ_opt = lsqnonlin(@(x) SuperParaboloidFunction(x, pcl), initial_lambda, min_lambda, max_lambda, opt_options  );
        disp(SQ_opt)
        SQ = [SQ_opt(1:5) SQ_opt(6:8) 0 0 0 -1 SQ_opt(end-2:end)];
        F = sum(SuperParaboloidFunction(SQ, pcl))/size(pcl,1);        
        SQ_P = SQ2PCL(SQ,size(pcl,1));
        SQ_pcl = SQ_P.v;
        [E, E_pcl_SQ, E_SQ_pcl ] = PCLDist(pcl,SQ_pcl);
        if E_init < E
            SQ = SQ_init;
            E = E_init;
            E_pcl_SQ = E_pcl_SQ_init;
            E_SQ_pcl = E_SQ_pcl_init;            
        end        
    end
end