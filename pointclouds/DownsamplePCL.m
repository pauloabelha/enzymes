function [ P ] = DownsamplePCL( P, min_n_points, downsample_segms, gen_new_faces )
    % check if we want to downsample the segms proportionately (default is false)
    if ~exist('downsample_segms','var')
       downsample_segms = 0; 
    end
    % check if we want to generate new faces (default is false)
    if ~exist('gen_new_faces','var')
        gen_new_faces = 0;
    end
    if isfield(P,'v') && ~isempty(P.v)
        ixs = randsample(1:size(P.v,1),min(min_n_points,size(P.v,1)));
        orig_pcl_n_pts = size(P.v,1);
        P.v = P.v(ixs,:);
        if isfield(P,'n') && ~isempty(P.n)
            P.n = P.n(ixs,:);
            if size(P.n,1) ~= size(P.v,1)
                warning('Point cloud has a different number of normal vector than points');
            end
        end
        if gen_new_faces
            P.f = delaunay(P.v(:,1), P.v(:,2), P.v(:,3));
            % faces must be 0-indexed
            if sum(min(P.f)) == size(P.f,2)
                P.f = P.f -1;
            end
        else
            P.f = [];
        end
        P.u = zeros(size(P.v,1),1);
        P.c = repmat([255 255 255],size(P.v,1),1);
    end
    if isfield(P,'segms') && downsample_segms
       for i=1:size(P.segms,2)
           segm_prop_n_pts = ceil((size(P.segms{i}.v,1)/orig_pcl_n_pts)*min_n_points);
           % we need at least 16 points because we need n_pts > sq_params for the optimasation
           segm_prop_n_pts = max(segm_prop_n_pts,16);
           ixs = randsample(1:size(P.segms{i}.v,1),min(segm_prop_n_pts,size(P.segms{i}.v,1)));
           P.segms{i}.v = P.segms{i}.v(ixs,:);
           if isfield(P.segms{i},'n') && ~isempty(P.segms{i}.n)
               P.segms{i}.n = P.segms{i}.n(ixs,:);
           end
       end        
    end   
end

