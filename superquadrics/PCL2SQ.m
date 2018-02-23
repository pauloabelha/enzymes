%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% By Paulo Abelha (p.abelha@abdn.ac.uk) 2017
%
%% Fits superquadrics and superparaboloids to a point cloud
%   (SQ is short for superquadric/superparaboloid; pcl is short for point cloud)
% Inputs:
%   P - PointCloud struct or an Nx3 matrix
%   n_attempts - number of fitting attempts (default is 1)
%   plot_fig - whether to plot the result at the end (default is false)
%   verbose - whether to show info as funciton runs (default is false)
%   fitting_modes - 1x5 array with the required types of SQ to try
%       each entry should be either 0 or 1 for trying or not the ype
%       Type order is: normal; tapered; bent; toroid; and paraboloid
%       e.g. [1 0 1 0 1] will try normal, bent and paraboloid SQs
%       (default is normal: [1 0 0 0 0])
%       Toroid is currently not working
%   try_to_clean_segm - whether to try to clean parts of a bad segmentation (default is false)
%
% Outputs:
%   SQs - the fitted SQs
%   TOT_ERROR - the total error of the fitting (considering all segments)
%   SEGM_ERRORS - error per segm
%   SEGM_ERRORS_PCL_SQ - error of the pcl in relation to the SQ
%   SEGM_ERRORS_SQ_PCL - error of the SQ in relation to the pcl
%   SQs_pcls - uniformly sampled pcls of the SQs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ SQs, TOT_ERROR, SEGM_ERRORS, SEGM_ERRORS_PCL_SQ, SEGM_ERRORS_SQ_PCL, SQ_pcls, Es, E_pcl_SQs, E_SQ_pcls ] = PCL2SQ( P, plot_fig, n_attempts, verbose, parallel, try_to_clean_segm )
    %% constants
    % max number of points (pcls with more than this will be downsampled)
    % increase this too much at your own risk of freezing the machine :)
    MAX_PCL_N_PTS = 1000;
    %% sanity checks
    if ~exist('P','var')
        error('No argument given: First argument needs to be a PointCloud or an Nx3 matrix');
    else
        if ~isstruct(P)
            CheckNumericArraySize(P,[Inf 3]);
            P = PointCloud(P);
        end
        CheckIsPointCloudStruct(P);
    end
    if ~exist('n_attempts','var')
        n_attempts = 1;
    else
        CheckNumericArraySize(n_attempts,[1 1]);
        if n_attempts < 1
            error('Second arugment, number of attempts, should be a positive number');
        end
    end
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    if ~exist('verbose','var')
        verbose = 0;
    end
    if ~exist('parallel','var')
        parallel = 1;
    end
    if ~exist('try_to_clean_segm','var')
        try_to_clean_segm = 0;
    end    
    %% initialise variables
    n_segms = size(P.segms,2);
    SQs = cell(1,n_segms);    
    SEGM_ERRORS = zeros(1,n_segms);
    SEGM_ERRORS_PCL_SQ = zeros(1,n_segms); 
    SEGM_ERRORS_SQ_PCL = zeros(1,n_segms);
    %% fit SQs to each segment
    for i=1:n_segms      
        pcl = P.segms{i}.v;
        % try to clean bad segmentation
        if try_to_clean_segm
            pcl = RemovePCLRangePeaks( pcl );
        end
        % downsample pcl
        pcl = pcl(randsample(size(pcl,1),min(size(pcl,1),MAX_PCL_N_PTS)),:);  
        % fit the SQ to the pcl
        n_SQs = n_attempts*4*4;
        SQs_fit = zeros(n_SQs,15);
        Es = zeros(n_SQs,1);
        E_pcl_SQs = Es;
        E_SQ_pcls = Es;
        ix_end = 0;
        for ix_attempt=1:n_attempts*4     
            ix_beg = ix_end + 1;
            ix_end = ix_end + 4;
            [SQs_fit(ix_beg:ix_end,:),Es(ix_beg:ix_end),E_pcl_SQs(ix_beg:ix_end),E_SQ_pcls(ix_beg:ix_end)] = FitSQtoPCL(pcl,ix_attempt,verbose,[],parallel);
        end        
        [SEGM_ERRORS(i), ix_best] = min(Es);
        SQs{i} = SQs_fit(ix_best,:);        
        SEGM_ERRORS_PCL_SQ(i) = E_pcl_SQs(ix_best);
        SEGM_ERRORS_SQ_PCL(i) = E_SQ_pcls(ix_best);        
    end
    % get total error
    TOT_ERROR = sum(SEGM_ERRORS)/size(SEGM_ERRORS,1);
    % plot results
    SQ_colours = {'.k' '.c' '.y' '.b' '.g' '.r'};
    if plot_fig
        PlotPCLSegments(P);
        hold on;        
    end 
    if plot_fig || nargout > 5
        SQ_pcls = PlotSQs(SQs,20000,0,SQ_colours,plot_fig);
    end
end