%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
%
%% Merges two segments of a PointCloud object
%
% You can provide the labels of the segments or the segments' indexes
% If the function receives only three params, it assumes it is receiving
% labels
% If you give the function a fourth param with value 1, it will consider 
% the second and third param as the indexes of the segments
%
% Inputs:
%   P - Point cloud object
%   label1 - integer of segment to receive the merged ones with label2
%   label2 - integer of segment to merge to label1
%   flag_segm_ixs - integer (considered as a boolen value: 0 or 1)
%   plot_fig - whether to plot the resulting pcl (default is 0)
% Outputs:
%   P with the desired segments merged
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ P ] = MergePointCloudSegments( P, label1, label2, flag_segm_ixs, plot_fig )
    if ~exist('P','var') || ~exist('label1','var') || ~exist('label2','var')
        error('Function needs three params');
    end
    if ~exist('flag_segm_ixs','var')
        flag_segm_ixs = 0;
    end
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    CheckIsPointCloudStruct( P );
    if size(P.segms) < 2
        error('Pointcloud needs to have at least two segments');
    end
    CheckIsScalar(label1);
    CheckIsScalar(label2);
    labels = unique(P.u);
    % get the segm indexes according to the given params
    segm1_found = 0;
    segm2_found = 0;
    if flag_segm_ixs
        ix1 = label1;
        ix2 = label2;
        if ix1 < 1 || ix1 > size(P.segms,2)
            error(['Index ' ix1 ' is smaller than 1 or exceeds the number ' size(P.segms,2) ' of segments in the point cloud']);
        end
        if ix2 < 1 || ix2 > size(P.segms,2)
            error(['Index ' num2str(ix2) ' is smaller than 1 or exceeds the number ' num2str(size(P.segms,2)) ' of segments in the point cloud']);
        end
        for i=1:size(labels,1)
            if i == ix1
                label1 = labels(i);
                segm1_found  =1;
            end
            if i == ix2
                label2 = labels(i);
                segm2_found  =1;
            end
        end 
    else       
        for i=1:size(labels,1)
            if labels(i) == label1
                ix1 = i;
                segm1_found = 1;
            end
            if labels(i) == label2
                ix2 = i;
                segm2_found = 1;
            end
        end
        if ~segm1_found
            error(['Could not find segment with label ' num2str(label1)]); 
        end
        if ~segm2_found
            error(['Could not find segment with label ' num2str(label2)]); 
        end
    end
    
    color_label1 = P.c(P.u==label1,:);
    ixs_label2 = P.u==label2;
    P.u(ixs_label2) = label1;
    P.c(ixs_label2,:) = repmat(color_label1(1,:),size(P.c(ixs_label2,:),1),1);   
    
    new_segms = {};
    for i=1:size(P.segms,2)
        if i == ix1
            new_segms{end+1}.v = [P.segms{ix1}.v; P.segms{ix2}.v];
            new_segms{end}.n = [P.segms{ix1}.v; P.segms{ix2}.n];  
            continue;
        end
        if i == ix2
            continue;
        end
        new_segms{end+1}.v = P.segms{i}.v;
        new_segms{end}.n = P.segms{i}.n;
    end
    P.segms = new_segms;
    
    if plot_fig
        PlotPCLSegments(P);
    end
end

