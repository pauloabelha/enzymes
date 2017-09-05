%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% By Paulo Abelha (p.abelha@abdn.ac.uk)
%
% Inputs:
%   points - M * N matrix of N-dimensional points
%   MAX_EXTRA_MEM - max extra memory to use for function (in bytes)
% Outputs:
%   dists_closest - 1 * M array, for each point, with the distance to its closest point
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ sampled_points ] = BridgeSampling( points, n_connections, scores, min_score, max_score )
    if ~exist('n_connections','var')
        n_connections = 10;
    end
    if ~exist('scores','var')
        scores = zeros(size(points,1),1);
        min_score = -Inf;
        max_score = Inf;
    end
    if ~exist('min_score','var')
        error('When a scores vector is given, you need to define a minimum score');
    end
    if ~exist('max_score','var')
        error('When a scores vector is given, you need to define a maximum score');
    end
    % get a distribution of distances between a point and its closest point
    normalise_points = true;
    orig_points = points;
    [ dists_closest, ixs_closest, points ] = GetDistsToClosestPoint( points, normalise_points );
    n_points = size(points,1);
    sampled_points = [];
    overall_mean_dist = mean(dists_closest);
    perc_mean_dist = 0.2;
    visited_ixs = false(1,n_points);
    tot_toc = 0;
    n_visited_points = 0;
    curr_point_ix = 1;
    mean_dist = overall_mean_dist*10;
    max_dist = mean_dist+std(dists_closest);
    while n_visited_points < n_points && ~all(visited_ixs)   
        tic;
        n_visited_points = n_visited_points + 1;    
        visited_ixs(curr_point_ix) = true;
        curr_point = points(curr_point_ix,:);        
        closest_point_ix = ixs_closest(curr_point_ix);
        if visited_ixs(closest_point_ix)
            while visited_ixs(curr_point_ix)
                curr_point_ix = randi(size(visited_ixs,2),1,1);
                if sum(visited_ixs) >= n_points
                    break;
                end
            end
            continue;
        end
        closest_point = points(closest_point_ix,:);
        dist_closest = pdist([curr_point;closest_point]);
        if dist_closest <= mean_dist*(1+perc_mean_dist) && ~visited_ixs(closest_point_ix)
            mean_dist = (mean_dist+dist_closest)/2;            
            sampled_points = BridgeSampler(orig_points(curr_point_ix,:),orig_points(closest_point_ix,:),n_connections,sampled_points,scores(curr_point_ix),scores(closest_point_ix),min_score,max_score);
            curr_point_ix = ixs_closest(curr_point_ix);
        else
            non_visited_points = points(~visited_ixs,:);
            mean_dist = overall_mean_dist;
            point_isolated = 1;
            for i=1:size(non_visited_points,1)
                neighbour_point = non_visited_points(i,:);
                curr_dist = pdist([curr_point;neighbour_point]);
                if curr_dist > max_dist
                    continue;
                end
                if curr_dist <= mean_dist*(1+perc_mean_dist)                                   
                    sampled_points = BridgeSampler(curr_point,neighbour_point,n_connections,sampled_points,scores(curr_point_ix),scores(closest_point_ix),min_score,max_score);
                    curr_point_ix = i;
                    point_isolated = 0;
                    break;
                else
                    mean_dist = (mean_dist+curr_dist)/2; 
                end
            end
            if point_isolated
                % sample non visited point to start from
                while visited_ixs(curr_point_ix)
                    curr_point_ix = randi(size(visited_ixs,2),1,1);
                    if sum(visited_ixs) >= n_points
                        break;
                    end
                end
            end
        end
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,n_visited_points,n_points);
    end
%     sampled_points = [points; sampled_points];
    %sampled_points = sampled_points(randi(size(sampled_points,1),1,size(sampled_points,1)),:);
end


function sampled_points = BridgeSampler(curr_point,neighbour_point,n_connections,sampled_points,score_curr_point,score_neighb_point,min_score,max_score)
    new_sampled_points = [];
    if score_curr_point >= min_score && score_neighb_point >= min_score &&  score_curr_point <= max_score && score_neighb_point <= max_score
        bridge_vector = neighbour_point - curr_point;
        new_sampled_points = zeros(n_connections,size(curr_point,2));
        for i=1:n_connections
            new_sampled_points(i,:) = curr_point + (bridge_vector*i/n_connections);
        end
    end
    sampled_points = [sampled_points; new_sampled_points];
end

