%Given a seed and a probability distribution over SQs, returns a fitted SQ
%pcl is a point cloud
% seed is a point in pcl (may be empty, in which case select random seed)
% As surf_tolerance increases, so are the point cloud boundaries (in m) 
% beyond the SQ that will be segmented along with it
function [pcl_SQ, pcl_out1, pcl_out2] = splitPclFromSQ_kmeans( pcl, SQ )
   surf_tolerance = 100;
   surface_boundary = 1+surf_tolerance;
   F = RecoveryFunctionSQ2(SQ, pcl); 
   pcl_SQ = pcl(F<=surface_boundary,:);
   pcl_out = pcl(F>surface_boundary,:);
   idx = kmeans(pcl_out,2) ;
   pcl_out1 = pcl_out(idx == 1,:);
   pcl_out2 = pcl_out(idx == 2,:);
   if length(pcl_out2) > length(pcl_out1)
       pcl_out_temp = pcl_out1;
       pcl_out1 = pcl_out2;
       pcl_out2 = pcl_out_temp;
   end
%    min_boundary = min(mean(pcl_out2)+std(pcl_out2),mean(pcl_out2)-std(pcl_out2));
%    max_boundary = max(mean(pcl_out2)+std(pcl_out2),mean(pcl_out2)-std(pcl_out2));
%    pcl_out2 = pcl_out2(pcl_out2(:,1)>=min_boundary(1),:);
%    pcl_out2 = pcl_out2(pcl_out2(:,2)>=min_boundary(2),:);
%    pcl_out2 = pcl_out2(pcl_out2(:,3)>=min_boundary(3),:);
%    pcl_out2 = pcl_out2(pcl_out2(:,1)<=max_boundary(1),:);
%    pcl_out2 = pcl_out2(pcl_out2(:,2)<=max_boundary(2),:);
%    pcl_out2 = pcl_out2(pcl_out2(:,3)<=max_boundary(3),:);
end

