function [ P ] = FuseSegmIntoOthers( P, segm_to_fuse_label, verbose )

    if ~exist('verbose','var')
        verbose = 0;
    end
    %% maximum acceptable distance for fusing 
    MAX_DIST = 0.3;
    %% minum acceptable distance for breaking out of searching for closeby points
    MIN_DIST = 0.01;
    %% mapping structure to get the index of a segment given its color
    eq_labels = [unique(P.u)'; 1:size(unique(P.u),1)];    
    %% run through every point in every swiss cheese segment
    % and give it the colour of the first point with MIN_DIST to it
    ix_segm = eq_labels(2,eq_labels(1,:)==segm_to_fuse_label);
    if isempty(ix_segm)
        disp('No segm to fuse');
        return;
    end   
    P.segms{eq_labels(2,eq_labels(1,:)==segm_to_fuse_label)} = {};
    
    %% create hashmap from 3D point (string) to its index
    pts_str = cell(size(P.v,1),1);
    parfor pi=1:size(P.v,1) pts_str{pi} = num2str(P.v(pi,:)); end
    keys = pts_str; 
    values = 1:size(P.v,1);
    values=values';
    pt_ix_map = containers.Map(keys, values);
    %% create pcl with only swiss cheese segm points
    pcl_sc = P.v(P.u==segm_to_fuse_label,:);
    %% loop through every swiss cheese ponint change its segment
%     tot_toc = 0;
%     for i=1:size(pcl_sc,1)
%         tic
%         pt_sc = pcl_sc(i,:);
%         pt_sc_str = num2str(pt_sc);
%         ix_pt_sc = pt_ix_map.values({pt_sc_str});
%         ix_pt_sc = ix_pt_sc{1};  
%         
%         sphere_radius = MIN_DIST;
%         non_sc_pt_in_sphere = [];
%         max_safe_iter = 1e6;
%         ix_safe_iter = 0;
%         while isempty(non_sc_pt_in_sphere)  
%             ix_safe_iter = ix_safe_iter + 1;
%             if ix_safe_iter >= max_safe_iter
%                 error('');
%             end
%             SQ_sphere = [sphere_radius sphere_radius sphere_radius 1 1 0 0 0 0 0 0 0 pt_sc];
%             F1 = SQFunctionNormalised( SQ_sphere, P.v, [] ); 
%             F2 = SQFunction( SQ_sphere, P.v, [] );
%             pts_in_sphere = P.v(F2<=1,:);
%             pts_in_sphere_str = cell(size(pts_in_sphere,1),1);
%             parfor pi=1:size(pts_in_sphere,1) pts_in_sphere_str{pi} = num2str(pts_in_sphere(pi,:)); end
%             ixs = pt_ix_map.values(pts_in_sphere_str);
%             ixs = cell2mat(ixs);
%             colour_pts_in_sphere = P.u(ixs);
%             non_sc_pt_in_sphere = pts_in_sphere(colour_pts_in_sphere ~= segm_to_fuse_label,:);
%             if isempty(non_sc_pt_in_sphere)
%                 sphere_radius = sphere_radius*2;
%                 continue;
%             end
%             curr_min_dist = 1e10;
%             for j=1:size(non_sc_pt_in_sphere,1)
%                 curr_dist = pdist([pt_sc; non_sc_pt_in_sphere(j,:)]);
%                 if curr_dist < curr_min_dist
%                     curr_min_dist = curr_dist;
%                     min_dist_ix = j;
%                     if curr_min_dist <= MIN_DIST
%                         break;
%                     end
%                 end
%             end
%             if curr_min_dist <= MIN_DIST
%                 break;
%             end
%         end
%         best_alt_pt = non_sc_pt_in_sphere(min_dist_ix,:);
%         best_alt_pt_str = num2str(best_alt_pt);
%         ix_alt_pt = pt_ix_map.values({best_alt_pt_str});
%         ix_alt_pt = ix_alt_pt{1};    
%     
%         ix_segm = eq_labels(2,eq_labels(1,:)==P.u(ix_alt_pt));
%         P.segms{ix_segm}.v(end+1,:) = P.v(ix_pt_sc,:);
%         P.segms{ix_segm}.n(end+1,:) = P.n(ix_pt_sc,:);
%         P.u(ix_pt_sc) = P.u(ix_alt_pt);
%         if isfield(P,'c') && ~isempty(P.c)
%             P.c(ix_pt_sc,:) = P.c(ix_alt_pt,:);
%         end       
%         perc_completed = ceil((i/size(pcl_sc,1))*100);
%         tot_toc = tot_toc+toc;
%         avg_toc = tot_toc/i;
%         estimated_time_hours = (avg_toc*(size(pcl_sc,1)-i))/(24*60*60);
%         disp(['Estimated time to finish (HH:MM:SS): ' datestr(estimated_time_hours, 'HH:MM:SS') '    ' num2str(perc_completed) ' %']);
%     end
    
        
    
    tot_toc = 0;
    for j=1:size(P.v,1)
        tic
        % continue if not swiss cheese pt
        if P.u(j) ~= segm_to_fuse_label
            continue;
        end
        % if we are here, current pt is a swiss cheese pt
        % Get new segm label as the label of the first pt,
        % which is not a swiss cheese,
        % with at most MIN_DIST to the swiss cheese pt
        found_pt = 0;
        curr_min_dist = 1e10;
        curr_min_dist_ix = 0;
        
        for k=1:size(P.v,1)
            curr_dist = pdist([P.v(j,:);P.v(k,:)]);
            if curr_dist < curr_min_dist && P.u(k) ~= segm_to_fuse_label
                curr_min_dist = curr_dist;
                curr_min_dist_ix = k;
                if curr_min_dist <= MIN_DIST
                    break;
                end
            end
        end
        k = curr_min_dist_ix;
        if curr_min_dist <= MAX_DIST
            ix_segm = eq_labels(2,eq_labels(1,:)==P.u(k));
            P.segms{ix_segm}.v(end+1,:) = P.v(j,:);
            if isfield(P.segms{ix_segm},'n') && ~isempty(P.segms{ix_segm}.n)
                P.segms{ix_segm}.n(end+1,:) = P.n(j,:);
            end
            P.u(j) = P.u(k);
            if isfield(P,'c') && ~isempty(P.c)
                P.c(j,:) = P.c(k,:);
            end
            found_pt = 1;
        end
%         for k=1:size(P.v,1)
%             if P.u(k) ~= segm_to_fuse_label && pdist([P.v(j,:);P.v(k,:)]) <= MIN_DIST
%                 ix_segm = eq_labels(2,eq_labels(1,:)==P.u(k));
%                 P.segms{ix_segm}.v(end+1,:) = P.v(j,:);
%                 P.segms{ix_segm}.n(end+1,:) = P.n(j,:);
%                 P.u(j) = P.u(k);
%                 P.c(j,:) = P.c(k,:);
%                 found_pt = 1;                
%                 break;
%             end                
%         end
        if ~found_pt
            warning(['Could not fuse point #' num2str(j) ' (' num2str(P.v(j,:)) ')']);
            error(['Could not fuse point #' num2str(j) ' (' num2str(P.v(j,:)) ')']);
        end
        perc_completed = ceil((j/size(P.v,1))*100);
        if verbose
            tot_toc = tot_toc+toc;
            avg_toc = tot_toc/j;
            estimated_time_hours = (avg_toc*(size(P.v,1)-j))/(24*60*60);
            disp(['Estimated time to finish (HH:MM:SS): ' datestr(estimated_time_hours, 'HH:MM:SS') '    ' num2str(perc_completed) ' %']);
        end
    end       
    if verbose
        disp(['Total elapsed time: ' num2str(tot_toc) ' s']);
    end
    segms = {};
    for i = 1:size(P.segms,2)
        if ~isempty(P.segms{i})
            segms{end+1} = P.segms{i};
        end
    end
    P.segms = segms;
end


