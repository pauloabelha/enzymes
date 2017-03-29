% try to rotate the superquadric around its X and Y axes to find other
% possible fits, if the fit is good it is retrned in a list of other
% possible fits
function [ SQs_alt, ERRORS, ORIG_ERRORS ] = GetRotationSQFits( SQs, Ps, fit_threshold, rmv_empty )
    %% check if should remove empty alt SQs (bad fits) - default is 0
    if ~exist('rmv_empty','var')
        rmv_empty = 0;
    end
    %% check input SQs
    for i=1:numel(SQs)
        CheckNumericArraySize(SQs{i},[1 15]);
    end
    %% get default fit threshold, if not defined
    if ~exist('fit_threshold','var')
        fit_threshold = 2;
    end
    %% proportional multiplier for accepting fits worse than orig error
    PROP_THRESHOLD_ORIG_ERROR = 1.5;
    %% define downsampling res for fitting comparison
    N_POINTS = 2000;
    %% initialise variables for parallel loop
    ORIG_ERRORS = zeros(1,numel(SQs));
    ERRORS = zeros(6,size(SQs,2));
    SQs_alt = cell(6,size(SQs,2));
    %% get the alternative SQs
    for i=1:numel(SQs)        
        % downsample the pcl for fit error comparison
        Ps{i} = DownsamplePCL( Ps{i}, N_POINTS, 1 );
        % get the pointcloud for the SQ
        SQ_pcl = UniformSQSampling3D(SQs{i},0,size(Ps{i}.v,1));
        % get the error between orig SQ and the pcl
        E_orig = PCLDist( SQ_pcl, Ps{i}.v );
        ORIG_ERRORS(i) = E_orig;
        %% get the 5 alternative SQs, accumulate if the fit is good
        % define SQ ix 
        SQs_alt_j = cell(6,1);
        parfor j=1:4
            alt_SQ = SQs{i};
            alt_SQ(6:8) = [0 0 0];
            rot = GetRotMtx((j-1)*pi/2,'y');
            alt_SQ = RotateSQWithRotMtx(alt_SQ,rot);
            if mod(j,2) == 0
                alt_SQ(1) = SQs{i}(3);
                alt_SQ(3) = SQs{i}(1);
            end
            alt_SQ = RotateSQWithRotMtx(alt_SQ,GetEulRotMtx(SQs{i}(6:8))); 
            alt_SQ_pcl = UniformSQSampling3D(alt_SQ,0,size(Ps{i}.v,1));
            E = PCLDist( alt_SQ_pcl,Ps{i}.v );
            ERRORS(j,i) = E;
            % if fit is good, accumulate SQ
            if E <= fit_threshold || E <= (E_orig*PROP_THRESHOLD_ORIG_ERROR)
                SQs_alt_j{j} = alt_SQ;                
            end
        end        
        parfor j=5:6
            alt_SQ = SQs{i};
            alt_SQ(6:8) = [0 0 0];
            if j == 5 
                theta=pi/2;
            else
                theta=3*pi/2;
            end
            rot = GetRotMtx(theta,'x');
            alt_SQ = RotateSQWithRotMtx(alt_SQ,rot);
            alt_SQ(2) = SQs{i}(3);
            alt_SQ(3) = SQs{i}(2);
            alt_SQ = RotateSQWithRotMtx(alt_SQ,GetEulRotMtx(SQs{i}(6:8)));
            alt_SQ_pcl = UniformSQSampling3D(alt_SQ,0,size(Ps{i}.v,1));
            E = PCLDist( alt_SQ_pcl,Ps{i}.v );
            ERRORS(j,i) = E;
            % if fit is good, accumulate SQ
            if E <= fit_threshold || E <= (E_orig*PROP_THRESHOLD_ORIG_ERROR)
                SQs_alt_j{j} = alt_SQ;                
            end
        end
        SQs_alt(:,i) = SQs_alt_j;
    end   
    %% remove badly fitted alt SQs (if required) - return is flattened
    if rmv_empty
        new_alt_SQs = {};
        new_ERRORS = [];
        for i=1:size(SQs_alt,1)
            for j=1:size(SQs_alt,2)
                if ~isempty(SQs_alt{i,j})
                    new_alt_SQs{end+1} = SQs_alt{i,j};
                    new_ERRORS(end+1) = ERRORS(i,j);
                end
            end
        end
        SQs_alt = new_alt_SQs;
        ERRORS = new_ERRORS;
    end
end