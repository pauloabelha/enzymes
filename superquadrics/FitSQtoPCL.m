function [SQs,Es,E_pcl_SQs,E_SQ_pcls] = FitSQtoPCL(pcl,ix_attempt,verbose,fit_constraints,parallel)
    if ~exist('fit_constraints','var') || isempty(fit_constraints)
        fit_constraints='';
    end
    % set optimisation preferences
    MIN_N_POINTS = 20;
    if exist('verbose','var') && verbose
        display_iter = 'iter';
    else
        display_iter = 'off';
    end
    opt_options = optimset('Display',display_iter,'TolX',1e-10,'TolFun',1e-10,'MaxIter',1000,'MaxFunEvals',1000); 
    if size(pcl,1) <= MIN_N_POINTS
        error(['Point cloud has only ' num2str(size(pcl,1)) ' points and the minimum is ' num2str(MIN_N_POINTS)]);
    end    
    if ~exist('parallel','var')
        parallel = 1;
    end
    pca_pcl = pca(pcl);
    pcl = pcl*pca_pcl;
    [~, pcl_scale] = PCLBoundingBoxVolume( pcl );
    %% fit in parallel
    SQs = zeros(4,15);
    Fs = zeros(4,1); Es = Fs; E_pcl_SQs = Fs; E_SQ_pcls = Fs; types= Fs;
    inv_pca_pcl = inv(pca_pcl);
    if parallel
        parfor i=1:4
            [SQs(i,:),~,Es(i,:),E_pcl_SQs(i,:),E_SQ_pcls(i,:),types(i,:)] = FitSQtoPCL_type(pcl,pcl_scale,ix_attempt,opt_options,i,fit_constraints,inv_pca_pcl);  
        end
    else
        for i=1:4
            [SQs(i,:),~,Es(i,:),E_pcl_SQs(i,:),E_SQ_pcls(i,:),types(i,:)] = FitSQtoPCL_type(pcl,pcl_scale,ix_attempt,opt_options,i,fit_constraints,inv_pca_pcl);  
        end
    end
end

function [ SQ,F,E,E_pcl_SQ, E_SQ_pcl,type ] = FitSQtoPCL_type(pcl,pcl_scale,ix_attempt,opt_options,type,fit_constraints,inv_pca_pcl)
    switch type        
        case 1            
            [ SQ,F,E,E_pcl_SQ, E_SQ_pcl ] = FitSQtoPCL_normal(pcl,pcl_scale,ix_attempt,opt_options,[1 0 0 0 0],fit_constraints);  
        case 2
            [ SQ,F,E,E_pcl_SQ, E_SQ_pcl ] = FitSQtoPCL_Tapering(pcl,pcl_scale,ix_attempt,opt_options,[0 1 0 0 0],fit_constraints);  
        case 3
            [ SQ,F,E,E_pcl_SQ, E_SQ_pcl ] = FitSQtoPCL_Bending(pcl,pcl_scale,ix_attempt,opt_options,[0 0 1 0 0],fit_constraints);  
        case 4
            [ SQ,F,E,E_pcl_SQ, E_SQ_pcl ] = FitSQToPCL_Paraboloid(pcl,pcl_scale,ix_attempt,opt_options,[0 0 0 0 1],fit_constraints);  
        otherwise
            error('Please define the type of fitting as 1-4');
    end
    %% perform the inverse transformation of the pca to get SQ to the original pcl' coordinate frame
    SQ(end-2:end) = SQ(end-2:end)*inv_pca_pcl;  
    SQ = RotateSQWithRotMtx(SQ, inv_pca_pcl');
    % deal with thins SQs
    if IsThinSQ(SQ)
        SQ(11) = 0;
    end
end
