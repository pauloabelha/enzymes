%Given a seed and a probability distribution over SQs, returns a fitted SQ
%pcl is a point cloud
% seed is a point in pcl (may be empty, in which case select random seed)
% As surf_tolerance increases, so are the point cloud boundaries (in m) 
% beyond the SQ that will be segmented along with it
function [pcl_SQ, pcl_out1, pcl_out2] = splitPclFromSQ( pcl, SQ, gamma2 )
    min_perc = 0.1;
    surface_boundary = 1+gamma2;
    F = SQFunction(SQ, pcl); 
    pcl_SQ = pcl(F<=surface_boundary,:);
    pcl_out = pcl(F>surface_boundary,:);
    if size(pcl_out,1)<(size(pcl,1)*2*min_perc)
        idx = ones(size(pcl_out,1),1);
    else
        idx = clusterdata(pcl_out,'linkage','ward','maxclust',1);
        %idx = kmeans(pcl_out,2);
    end
    pcl_out1 = pcl_out(idx == 1,:);
    pcl_out2 = pcl_out(idx == 2,:);
    
    
    
%     if size(pcl_out1,1)<(size(pcl,1)*min_perc)
%         pcl_out1=[];
%     end
%     if size(pcl_out2,1)<(size(pcl,1)*min_perc)
%         pcl_out2=[];
%     end
    
%     if isempty(pcl_out)
%         pcl_out1 = [];
%         pcl_out2 = [];
%     else
%         std_mult = 2;
%         mean_pcl_out = mean(pcl_out,1);
%         std_pcl_out = std(pcl_out,1);
%         min_boundary = min(mean_pcl_out+(std_mult*std_pcl_out),mean_pcl_out-(std_mult*std_pcl_out));
%         pcl_out1_ixs_x = pcl_out(:,1)>=min_boundary(1);
%         pcl_out1_ixs_y = pcl_out(:,2)>=min_boundary(2);
%         pcl_out1_ixs_z = pcl_out(:,3)>=min_boundary(3);
%         pcl_out1_ixs = pcl_out1_ixs_x & pcl_out1_ixs_y & pcl_out1_ixs_z;
%         pcl_out1 = pcl_out(pcl_out1_ixs == 1,:);
%         pcl_out2 = pcl_out(pcl_out1_ixs == 0,:);
%         if length(pcl_out2) > length(pcl_out1)
%             pcl_out_temp = pcl_out1;
%             pcl_out1 = pcl_out2;
%             pcl_out2 = pcl_out_temp;
%         end
%     end
end

