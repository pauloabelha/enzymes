
% recursively split the pcl and fit SQ
% come back up mergin the pieces

function [segms, counter] = DemocritusSegmentationNoFit( pcl, verbose, res, MIN_FIT_ERROR, plot_fig )
    % default is not verbose
    if ~exist('verbose','var')
        verbose = 0;
    end    
    % calculate resolution
    if ~exist('res','var') || res <= 0
        pcl = pcl*pca(pcl);
        res = range(pcl)/10;
        if verbose
            disp(['Using calculated resolution: ' num2str(res)]);
        end
    % use resolution given by user
    else
        if verbose
            warning(['Using given resolution: ' num2str(res)]);
        end
    end
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    [segms, segm_stack, segm_candidate, good_candidate, counter] = DemocritusSegmentationNoFit_Recur(  pcl, res, {}, {}, [], 0, MIN_FIT_ERROR, 0, 0, verbose);
    if verbose
        if isempty(segms)
            disp('Could not segment the pcl (try lowering the resolution; or increase allowed fit error (not recommended))');
        end
    end
    if ~isempty(segm_candidate)
        segms{end+1} = segm_candidate;
        [~,fit_error] = FreeFitting( PointCloud(segms{end}), 8, 0, 0, [1 0 0 0 0] );        
        if verbose && numel(segms) >= 2
            if fit_error <= MIN_FIT_ERROR
            segm_desc = 'good';
            else
                segm_desc = 'bad';
            end
            disp(['Added a final (' segm_desc ') segment!']);
            disp(['Final number of segments: ' num2str(numel(segms))]);
        end
    end
    if plot_fig
        hold off;
        figure;
        PlotPCLS(segms);
    end
end

function [segms, segm_stack, segm_candidate, good_candidate, counter] = DemocritusSegmentationNoFit_Recur( pcl, res, segms, segm_stack, segm_candidate, good_candidate, MIN_FIT_ERROR, counter, level_counter, verbose )
    MIN_PCL_SIZE = 0.001;
    MIN_PCL_N_PTS = 10;
    counter = counter + 1;
    if size(pcl,1) <= MIN_PCL_N_PTS || min(range(pcl)) < MIN_PCL_SIZE
        if verbose
            disp([blanks(level_counter) 'Found small piece - pcl too small']);
        end
        segm_stack{end+1} = pcl;
        segm_candidate = [segm_candidate; pcl];
        return;
    end    
    pca_pcl = pca(pcl);
    pcl = pcl*pca_pcl; 
    range_pcl = range(pcl);
    % revert pcl
    pcl = pcl/pca_pcl;
    [fitted_SQs,fit_error] = FreeFitting( PointCloud(pcl), 8, 0, 0, [1 0 0 0 0], 0 );
    fitted_SQ = fitted_SQs{1};
    if max(range_pcl) <= res    
        if verbose
            disp([blanks(level_counter) 'Found small piece - pcl below resolution (' num2str(fit_error) ')']);
        end        
        if isempty(segm_candidate)
            segm_candidate = pcl;
        else
            [segms, segm_stack, segm_candidate, good_candidate] = MergeSegmCandidates2(segms,segm_stack,segm_candidate,good_candidate,fitted_SQ,fit_error,pcl,MIN_FIT_ERROR,verbose,level_counter);
        end
        return;
    end    
    if fit_error > MIN_FIT_ERROR
        level_counter = level_counter + 1;
        pcl = pcl*pca_pcl; 
        pcls= CutPCLDemocritus2(pcl);
        % pcl_sib is pcl from sibling
        if verbose
            disp([blanks(level_counter) 'Found bad piece (' num2str(fit_error) ') - recursively calling its ' num2str(numel(pcls)) ' children']);
        end
        for i=1:numel(pcls)
            if verbose
                disp([blanks(level_counter) 'Children ' num2str(i) ' of ' num2str(numel(pcls))]);
            end
            pcls{i} = pcls{i}/pca_pcl;
            [segms, segm_stack, segm_candidate, good_candidate, counter] = DemocritusSegmentationNoFit_Recur( pcls{i}, res, segms, segm_stack, segm_candidate, good_candidate, MIN_FIT_ERROR, counter, level_counter, verbose );
        end        
        % found a bad fit -> current segm candidate is asserted as segm
    else
        if verbose
            disp([blanks(level_counter) 'Found good piece (' num2str(fit_error) ')']);
        end
        good_candidate = 1;
        if isempty(segm_candidate)
            segm_candidate = pcl;
        else
            [segms, segm_stack, segm_candidate, good_candidate] = MergeSegmCandidates2(segms,segm_stack,segm_candidate,good_candidate,fitted_SQ,fit_error,pcl,MIN_FIT_ERROR,verbose,level_counter);
        end
    end 
end

function [segms, segm_stack, segm_candidate, good_candidate] = MergeSegmCandidates2(segms,segm_stack,segm_candidate,good_candidate,fitted_SQ,fitted_SQ_error,pcl_fitted_SQ,MIN_FIT_ERROR,verbose,level_counter)
    % try to merge last segm (segms{end} with fitted_SQ (if good, segm expands; if bad, assert segm)
    pcl_merge = [segm_candidate; pcl_fitted_SQ];
    [~,fit_error_merge] = FreeFitting( PointCloud(pcl_merge), 8, 0, 0, [1 0 0 0 0] );
%     disp(['Merge fit error:  ' num2str(fit_error_merge)]);
    if fit_error_merge > MIN_FIT_ERROR
        % found a bad fit ->
        %   if current segm candidate is good
        %       -> assert segm candidate
        %       -> reinitialise segm candidate
        %   else
        %       -> put segm candidate as the merged segm
        if good_candidate            
            segms{end+1} = segm_candidate;
            if verbose
                disp([blanks(level_counter) 'Added a new segment! (' num2str(numel(segms)) ')']);
            end
            segm_stack{end+1} = segm_candidate;
            segm_candidate = pcl_fitted_SQ;
            good_candidate = fitted_SQ_error <= MIN_FIT_ERROR;           
        else
            % merge both segments into one candidate segm
            if verbose
                disp([blanks(level_counter) 'Merged two bad pieces into a bad piece']);
            end            
            if fitted_SQ_error <= MIN_FIT_ERROR                
                segms{end+1} = segm_candidate;
                if verbose
                    disp([blanks(level_counter) 'Added a new segment! (' num2str(numel(segms)) ')']);
                end
                segm_stack{end+1} = segm_candidate;
                segm_candidate = pcl_fitted_SQ;
                good_candidate = fitted_SQ_error <= MIN_FIT_ERROR;  
            else
                segm_candidate = [segm_candidate; pcl_fitted_SQ];
                good_candidate = 0;  
            end
        end        
    else
        % found a good fit -> merged SQ becomes segm candidate
        if verbose
            disp([blanks(level_counter) 'Merged two good pieces into a good piece']);
        end
        segm_candidate = [segm_candidate; pcl_fitted_SQ];
        good_candidate = 1; 
    end
end

function [ pcls ] = CutPCLDemocritus2( pcl )
    DIFF_RANGE_THRESHOLD = 0.03;
    range_pcl = range(pcl);
    res = range_pcl(1)/50;
    SLICE_PROP = res/range_pcl(1);
    dim1  =1;
    dim2 = 2;
    [~,dim1_sorted_ixs] = sort(pcl(:,dim1),'ascend');
    pcl = pcl(dim1_sorted_ixs,:);
    pcl_length=length(pcl);
    slice_length = floor(size(pcl,1)*SLICE_PROP);
    n_slices = floor(pcl_length/slice_length);
    ranges = zeros(n_slices,1);
    slices = cell(1,n_slices);
    slices{1} = pcl(1:slice_length,:); 
    ranges(1) = range(slices{1}(:,dim2));
    pcls = {};    
    for i=2:n_slices
        ix_begin = (i-1)*slice_length;
        slices{i} = pcl(ix_begin+1:ix_begin+slice_length,:); 
        ranges(i) = range(slices{i}(:,dim2)); 
    end
    diff_3_ranges = abs(diff(ranges,3));
    cut_points = diff_3_ranges>=DIFF_RANGE_THRESHOLD;
    pcl_stack = [slices{1}; slices{2}; slices{3}];
    for i=4:numel(cut_points)
        if cut_points(i-3)   
            pcls{end+1} = pcl_stack;
            pcl_stack = [];
        else
            pcl_stack = [pcl_stack; slices{i}];
        end
    end
    if ~isempty(pcl_stack)
        for i=i-5:numel(slices)
            pcl_stack = [pcl_stack; slices{i}];
        end
        pcls{end+1} = pcl_stack;
    end    
end


