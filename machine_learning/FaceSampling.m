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
function [ sampled_points, sampled_edges ] = FaceSampling( points, n_connections )
    if ~exist('n_connections','var')
        n_connections = 10;
    end
    CheckScalarInRange(n_connections,'closed-open',[1 Inf]);
    n_points = size(points,1);
    orig_points = points;
    [ dists_closest, ixs_closest, dists ] = GetSortedDistsPoints( points );
    min_dists_closest = dists_closest(:,1)';    
    sampled_points = [];
    visited_ixs = false(1,n_points);
    tot_toc = 0;
    n_visited_points = 0;
    curr_point_ix = 1;
    threshold = 3*mean(min_dists_closest); %mean(min_dists_closest)+3*std(min_dists_closest);
    sampled_edges = zeros(n_points,n_points);
    edge_ix = 0;
    while n_visited_points < n_points || ~all(visited_ixs)
        tic;
        % update visited points
        n_visited_points = n_visited_points + 1;    
        visited_ixs(curr_point_ix) = true;   
        % get neighbour indexes (should be sorted for efficiency)
        neighbours_ixs = ixs_closest(curr_point_ix,:);
        i=1;
        % if both distances are below threshold, sample the triangle formed by the 3 points
        while dists(curr_point_ix,neighbours_ixs(i)) <= threshold && dists(curr_point_ix,neighbours_ixs(i+1)) <= threshold && (sampled_edges(curr_point_ix,neighbours_ixs(i)) < 1 || sampled_edges(curr_point_ix,neighbours_ixs(i+1)) < 1)
            sampled_points = FaceSampler(orig_points(curr_point_ix,:),orig_points(neighbours_ixs(i),:),orig_points(neighbours_ixs(i+1),:),n_connections,sampled_points);
            edge_ix = edge_ix + 1;
            visited_ixs(neighbours_ixs(i)) = true; 
            visited_ixs(neighbours_ixs(i+1)) = true; 
            sampled_edges(curr_point_ix,neighbours_ixs(i)) = edge_ix;
            sampled_edges(neighbours_ixs(i),curr_point_ix) = edge_ix;
            sampled_edges(curr_point_ix,neighbours_ixs(i+1)) = edge_ix;
            sampled_edges(neighbours_ixs(i+1),curr_point_ix) = edge_ix;
            curr_point_ix = ixs_closest(curr_point_ix);     
            i=i+1;
        % else, get a new random point to start from
        end            
        curr_point_ix = GetRandomNonVisitedPointIx(visited_ixs);
        if curr_point_ix < 0
            break;
        end
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,n_visited_points,n_points,'Face sampling (perc means prop of points visited already): ');
    end
    sampled_points = sampled_points(randi(size(sampled_points,1),1,size(sampled_points,1)),:);
end

function sampled_points = FaceSampler(curr_point,neighbour_point1,neighbour_point2,n_connections,sampled_points)
    sampled_points = [sampled_points; UniformSampleTriangle(curr_point,neighbour_point1,neighbour_point2,n_connections)];
end

function point_ix = GetRandomNonVisitedPointIx(visited_ixs)
    % sample non visited point to start from
    point_ix = -1;
    if ~all(visited_ixs)
        point_ix = randi(size(visited_ixs,2),1,1);
        while visited_ixs(point_ix)
            point_ix = randi(size(visited_ixs,2),1,1);
        end
    end
end

