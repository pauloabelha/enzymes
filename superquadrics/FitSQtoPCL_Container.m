function [SQ,F,E,E_pcl_SQ, E_SQ_pcl ] = FitSQtoPCL_Container(pcl,pcl_scale,ix,opt_options,initial_lambda_in,fitting_modes)  
    SQ = zeros(15,1); F = Inf; E = Inf; E_pcl_SQ = Inf; E_SQ_pcl  =Inf;
    if fitting_modes(5) == 1
        [ SQ, F_vec, E, E_pcl_SQ, E_SQ_pcl ] = FitSuperParaboloid( pcl, 0, 0, pcl_scale, opt_options);   
        F = mean(F_vec);
        fit_improv_prop = 1;
        F = F*fit_improv_prop;
        E = E*fit_improv_prop;
        E_pcl_SQ = E_pcl_SQ*fit_improv_prop;
        E_SQ_pcl = E_SQ_pcl*fit_improv_prop;
    end
