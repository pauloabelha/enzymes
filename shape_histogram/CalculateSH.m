%calculates a shape-signature histogram according to the explanations in 
% @article{Schoeler2015,
% author = {Schoeler, Markus and Worgotter, Florentin},
% doi = {10.1109/TAMD.2015.2488284},
% file = {:C$\backslash$:/Users/Paulo/AppData/Local/Mendeley Ltd./Mendeley Desktop/Downloaded/Schoeler, Worgotter - 2015 - Bootstrapping the Semantics of Tools Affordance analysis of real world objects on a per-part basis.pdf:pdf},
% issn = {1943-0604},
% journal = {IEEE Transactions on Autonomous Mental Development},
% number = {99},
% pages = {1--1},
% title = {{Bootstrapping the Semantics of Tools: Affordance analysis of real world objects on a per-part basis}},
% url = {http://ieeexplore.ieee.org/lpdocs/epic03/wrapper.htm?arnumber=7293623},
% volume = {pp},
% year = {2015}
% }
function SH = CalculateSH( pcl, normals, n_points, nbins, angle_range, dist_range )
    zero_bound = 0;
% 	disp('Size of point cloud');
%     disp(size(pcl,1));
    %n_points = min(1000,min(size(pcl,1),n_points));
    %ixs_max_size = randsample(size(pcl,1),n_points);
    %pcl = pcl(ixs_max_size,:);
    %normals = normals(ixs_max_size,:);
    dist_rowvec = pdist(pcl);
    dist_rowvec = (dist_rowvec-min(dist_rowvec))/(max(dist_rowvec)-min(dist_rowvec));%(dist_rowvec-min(dist_rowvec))/(max(dist_rowvec)-min(dist_rowvec));
    %dist_rowvec = dist_rowvec - 0.5;
    angle_rowvec = pdist(normals,@(Xi,Xj) normal_dist(Xi,Xj,pcl,n_points,zero_bound));     
% 	disp('Percent non-negative angle values:');
% 	disp(size(angle_rowvec(angle_rowvec >= 0))/size(angle_rowvec));
%     disp(max(angle_rowvec));
%     disp(min(angle_rowvec));
%     disp('Size: ');
%     disp(size(pcl,1));
%     disp('Normals: ');
    %disp(size(normals,1));
    figure; 
    angle_step = sum(abs(angle_range))/(nbins-1);
    hist_angle_range = angle_range(1):angle_step:angle_range(2);
    dist_step = sum(abs(dist_range))/(nbins-1);
    hist_dist_range = dist_range(1):dist_step:dist_range(2);
    SH = histogram2(angle_rowvec,dist_rowvec,hist_angle_range,hist_dist_range,'FaceColor','flat');
    SH =  hist3([angle_rowvec; dist_rowvec]',{hist_angle_range, hist_dist_range});
    %colorbar;
end
% http://uk.mathworks.com/matlabcentral/answers/16243-angle-between-two-vectors-in-3d
% Answer by Jan Simon on 20 Sep 2011
function angle_dist = normal_dist(ANGVECTOR_i,ANGVECTORS_j,pcl,n_points,zero_bound)
    %get current i normal vector (that is compared to all the other j)
    i = n_points-size(ANGVECTORS_j,1);
    %calculate angle_dist between i angle vector and all the other j
    norm_XI = sqrt(sum(ANGVECTOR_i.^2,2));
    norm_XJ = sqrt(sum(ANGVECTORS_j.^2,2));  
    A = norm_XJ*ANGVECTOR_i - norm_XI*ANGVECTORS_j;
    B = norm_XJ*ANGVECTOR_i + norm_XI*ANGVECTORS_j;
    norm_1 = sqrt(sum(A.^2,2));
    norm_2 = sqrt(sum(B.^2,2));
    angle_dist = 2 * atan(norm_1 ./ norm_2);
    %get the Dij
    Dij = pcl(i+1:end,:) - repmat(pcl(i,:),size(pcl(i+1:end,:),1),1);
    
    normDij = Dij.^2;
    normDij = sum(normDij,2);
    normDij = sqrt(normDij);
    Dij = bsxfun(@times,Dij,normDij.^-1);
    
    %normalise Dij
%     Dij = bsxfun(@times,Dij,inv(norm(Dij)));
    %normalise all the j angle vectors
    ANGVECTORS_j = bsxfun(@times,ANGVECTORS_j,inv(norm(ANGVECTORS_j)));
    %get the decision of convexity
    convex = double(sum(bsxfun(@times,Dij,ANGVECTORS_j),2) > (0-zero_bound) & sum(bsxfun(@times,-Dij,repmat(ANGVECTOR_i,size(Dij,1),1)),2)> (0-zero_bound));
    %set every failed decision to be concave
    convex(convex==0) = -1;
    angle_dist = convex.*angle_dist;
end