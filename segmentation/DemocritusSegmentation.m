
% recursively split the pcl and fit SQ
% come back up mergin the pieces

function [segms, counter] = DemocritusSegmentation( pcl, res )
    [~, counter, segms, pcl_segms, segm_candidate, ~, pcl_segm_candidate] = DemocritusSegmentation_Recur( pcl, res, 0, {}, {}, [], 0, [] );
    if ~isempty(segm_candidate)
        segms{end+1} = segm_candidate;
        pcl_segms{end+1} = pcl_segm_candidate;
    end
    PlotPCLS(pcl_segms);
end

function [pcl, counter, segms, pcl_segms, segm_candidate, good_candidate, pcl_segm_candidate, SQs] = DemocritusSegmentation_Recur( pcl, res, counter, segms, pcl_segms, segm_candidate, good_candidate, pcl_segm_candidate)
    MIN_PCL_SIZE = 10;
    MIN_FIT_ERROR = 3;
    counter = counter + 1;
    pcls = CutPCLDemocritus2(pcl,0.005,1);
    if PCLBoundingBoxVolume(pcl) <= 2e-5 || numel(pcls) == 1
        pcl_segm_candidate = [pcl_segm_candidate; pcl];
        SQs{1} = [];        
        return;
    end    
    pca_pcl = pca(pcl);
    pcl = pcl*pca_pcl; 
    range_pcl = range(pcl);
    % revert pcl
    pcl = pcl/pca_pcl;
    [fitted_SQs,fit_error] = FreeFitting( PointCloud(pcl), 8, 1, 0, [1 0 0 0 0] );
    disp(['Fit error: ' num2str(fit_error)]);
    fitted_SQ = fitted_SQs{1};
    if range_pcl(1) < res    
        SQs{1} = fitted_SQ;
        if isempty(segm_candidate)
            segm_candidate = fitted_SQ;
            pcl_segm_candidate = pcl;
        else
            [segms, pcl_segms, segm_candidate, good_candidate, pcl_segm_candidate] = MergeSegmCandidates(segms,pcl_segms,segm_candidate,good_candidate,pcl_segm_candidate,fitted_SQ,fit_error,pcl,MIN_FIT_ERROR);
        end
        return;
    end        
    if fit_error > MIN_FIT_ERROR
        SQs_up = cell(1,numel(pcls,2));
        % pcl_sib is pcl from sibling
        for i=1:numel(pcls)
            [~,counter, segms, pcl_segms, segm_candidate, good_candidate, pcl_segm_candidate, SQs_sibling] = DemocritusSegmentation_Recur( pcls{i}, res, counter, segms, pcl_segms, segm_candidate, good_candidate, pcl_segm_candidate );
            SQs_up{i} = SQs_sibling;
        end
    else
        SQs_up = {};   
        good_candidate = 1;
        if isempty(segm_candidate)
            segm_candidate = fitted_SQ;
            pcl_segm_candidate = pcl;
        else
            [segms, pcl_segms, segm_candidate, good_candidate, pcl_segm_candidate] = MergeSegmCandidates(segms,pcl_segms,segm_candidate,good_candidate,pcl_segm_candidate,fitted_SQ,fit_error,pcl,MIN_FIT_ERROR);
        end
    end
    SQs = {fitted_SQ, SQs_up};     
end

function [segms, pcl_segms, segm_candidate, good_candidate, pcl_segm_candidate] = MergeSegmCandidates(segms,pcl_segms,segm_candidate,good_candidate,pcl_segm_candidate,fitted_SQ,fitted_SQ_error,pcl_fitted_SQ,MIN_FIT_ERROR)
    % try to merge last segm (segms{end} with fitted_SQ (if good, segm expands; if bad, assert segm)
%     pcl1 = UniformSQSampling3D(segm_candidate,0,2000);
%     pcl2 = UniformSQSampling3D(fitted_SQ,0,2000);
%     pcl_merge = [pcl1; pcl2];
    pcl_merge = [pcl_segm_candidate; pcl_fitted_SQ];
    [fitted_SQ_merge,fit_error_merge] = FreeFitting( PointCloud(pcl_merge), 8, 0, 0, [1 0 0 0 0] );
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
            pcl_segms{end+1} = pcl_segm_candidate;
            segm_candidate = fitted_SQ;  
            pcl_segm_candidate = pcl_fitted_SQ;
            good_candidate = fitted_SQ_error <= MIN_FIT_ERROR;            
        else
            % merge both segments into one candidate segm
            disp('Merged two bad fits');
            if fitted_SQ_error <= MIN_FIT_ERROR
                segms{end+1} = segm_candidate;
                pcl_segms{end+1} = pcl_segm_candidate;
                segm_candidate = fitted_SQ;  
                pcl_segm_candidate = pcl_fitted_SQ;
                good_candidate = fitted_SQ_error <= MIN_FIT_ERROR;  
            else
                segm_candidate = fitted_SQ_merge{1}; 
                pcl_segm_candidate = [pcl_segm_candidate; pcl_fitted_SQ];
                good_candidate = 0;  
            end
        end        
    else
        % found a good fit -> merged SQ becomes segm candidate
        disp('Merged two good fits');
        segm_candidate = fitted_SQ_merge{1};
        pcl_segm_candidate = [pcl_segm_candidate; pcl_fitted_SQ];
        good_candidate = 1; 
    end
end

function [ pcls, thresholds ] = CutPCLDemocritus( pcl, range_pcl, axis, res )
    SLICE_PROP = .02;
    DIFF_THRESH = 0.015;  
    dim1  =1;
    dim2 = 2;
    [~,dim1_sorted_ixs] = sort(pcl(:,dim1),'ascend');
    pcl = pcl(dim1_sorted_ixs,:);
    pcl_length=length(pcl);
    slice_length = ceil(size(pcl,1)*SLICE_PROP);
    n_slices = floor(pcl_length/slice_length);
    ranges = zeros(n_slices,1);
    diff_ranges = zeros(n_slices-1,1);
    slice = pcl(1:slice_length,:); 
    ranges(1) = range(slice(:,dim2));
    for i=2:n_slices
        ix_begin = (i-1)*slice_length;
        slice = pcl(ix_begin+1:ix_begin+slice_length,:); 
        ranges(i) = range(slice(:,dim2)); 
        diff_ranges(i-1) = abs(ranges(i) - ranges(i-1));
    end
    thresholds = [];
    average_diff = 0;
    average_diffs = [];
    pcls = {};
    pcl_end = size(pcl,1);
    for i=1:size(diff_ranges,1)
        if ~mod(i,5)
            average_diff = 0;
        end
        average_diff = (average_diff +  diff_ranges(i))/2;
        average_diffs = [average_diffs; average_diff];
        if average_diff > DIFF_THRESH
            if isempty(thresholds)
                pcl_cut_ix_beg = 0;
            else
                pcl_cut_ix_beg = thresholds(end);
            end
            thresholds = [thresholds; i];
            pcl_cut_ix_end = thresholds(end); 
            pcl_beg = (pcl_cut_ix_beg*slice_length) + 1;
            pcl_end = pcl_cut_ix_end*slice_length;
            pcls{end+1} = pcl(pcl_beg:pcl_end,:);
            average_diff = 0;
            break;
        end
    end
    if isempty(thresholds)
        % if couldn't smartly cut, cut it in half
        thresholds = min(pcl(:,1)) + range_pcl(1)/2;
        pcls{1} = pcl(pcl(:,1)<=thresholds(1),:);
        pcls{2} = pcl(pcl(:,1)>thresholds(1),:);
    elseif pcl_end < size(pcl,1)
        pcls{end+1} = pcl(pcl_end+1:end,:);
    end
%     pcls = GetMedianRangeBySlicingPcl( pcl, 1, 2, SLICE_PROP );
    %PlotPCLS(pcls);
    %hold on;

end


