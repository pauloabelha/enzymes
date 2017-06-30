function [SQ,ERROR,ERROR_vec,ERROR_PCL_SQ,ERROR_SQ_PCL] = FitSQtoPCL(pcl,n_attempts,verbose,fitting_modes,fit_constraints)
    % initialise errors
    ERROR_vec = Inf;
    ERROR = Inf;
    ERROR_PCL_SQ = Inf;
    ERROR_SQ_PCL = Inf;
    if ~exist('fit_constraints','var') || isempty(fit_constraints)
        fit_constraints='';
    end
    if ~exist('scale_slicing','var')
        scale_slicing = 1;
    end
    % set optimisation preferences
    MIN_N_POINTS = 20;
    if verbose
        display_iter = 'iter';
    else
        display_iter = 'off';
    end
    opt_options = optimset('Display',display_iter,'TolX',1e-10,'TolFun',1e-10,'MaxIter',50,'MaxFunEvals',1000); 
    if size(pcl,1) <= MIN_N_POINTS
        error(['Point cloud has only ' num2str(size(pcl,1)) ' points and the minimum is ' num2str(MIN_N_POINTS)]);
    end    
    pca_pcl = pca(pcl);
    pcl = pcl*pca_pcl;
    [~, pcl_scale] = PCLBoundingBoxVolume( pcl );
    %% fit in parallel
    n_tries = n_attempts*4;
    parfor i=1:n_tries
        [SQ_norm(i,:),F_norm(i),E_norm(i),E_pcl_SQ_norm(i),E_SQ_pcl_norm(i)] = FitSQtoPCL_normal(pcl,pcl_scale,i,opt_options,fitting_modes,fit_constraints);  
        [SQ_taper(i,:),F_taper(i), E_taper(i), E_pcl_SQ_taper(i),E_SQ_pcl_taper(i)] = FitSQtoPCL_Tapering(pcl,pcl_scale,i,opt_options,fitting_modes);
        [SQ_bend(i,:),F_bend(i), E_bend(i), E_pcl_SQ_bend(i),E_SQ_pcl_bend(i)] = FitSQtoPCL_Bending(pcl,pcl_scale,i,opt_options,fitting_modes);
        [SQ_tor(i,:),F_tor(i), E_tor(i), E_pcl_SQ_tor(i),E_SQ_pcl_tor(i)] = FitSQtoPCL_Toroid(pcl,pcl_scale,i,opt_options,SQ_norm(i,:),fitting_modes);
        [SQ_cont(i,:),F_cont(i), E_cont(i), E_pcl_SQ_cont(i),E_SQ_pcl_cont(i)] = FitSQToPCL_Paraboloid(pcl,pcl_scale,i,opt_options,fitting_modes);        
    end
    %% perform a rank voting with F and M
    F_tot = [F_norm'; F_taper'; F_bend'; F_tor'; F_cont'];
    E_tot = [E_norm'; E_taper'; E_bend'; E_tor'; E_cont'];
    E_tot_pcl_SQ = [E_pcl_SQ_norm'; E_pcl_SQ_taper'; E_pcl_SQ_bend'; E_pcl_SQ_tor'; E_pcl_SQ_cont'];
    E_tot_SQ_pcl = [E_SQ_pcl_norm'; E_SQ_pcl_taper'; E_SQ_pcl_bend'; E_SQ_pcl_tor'; E_SQ_pcl_cont'];
    %disp(E_tot);
    if size(E_tot(E_tot<Inf),1) < 1
        warning('Could not fit any SQ');
        SQ = [];
        return;
    end
    [ ~, SQ_min_ix ] = GetRankVector( E_tot, 0.001 );
    SQ_tot = {SQ_norm; SQ_taper; SQ_bend; SQ_tor; SQ_cont};
    best_option = ceil(SQ_min_ix/n_tries);
    best_seed = SQ_min_ix-(ceil(SQ_min_ix/n_tries)-1)*n_tries;     
    SQ_best_option = SQ_tot{best_option};
    if iscell(SQ_best_option)
       SQ = SQ_best_option{best_seed};
    else
        SQ = SQ_best_option(best_seed,:);
    end       
    CheckNumericArraySize(SQ,[1 15]);
    SQ(end-2:end) = SQ(end-2:end)*inv(pca_pcl);  
    SQ = RotateSQWithRotMtx(SQ, inv(pca_pcl)');
    %% get errors
    ERROR_vec = F_tot(SQ_min_ix);
    ERROR = E_tot(SQ_min_ix);
    ERROR_PCL_SQ = E_tot_pcl_SQ(SQ_min_ix);
    ERROR_SQ_PCL = E_tot_SQ_pcl(SQ_min_ix);
    %% deal with thins SQs
    if IsThinSQ(SQ)
        SQ(11) = 0;
    end
end
