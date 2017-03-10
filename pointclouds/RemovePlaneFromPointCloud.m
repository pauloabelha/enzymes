function RemovePlaneFromPointCloud( pcl_complete_filepath, new_pcl_complete_filepath )
    pcl_obj_paulo=1;
    max_pcl_length_for_ransac = 20000;
    P = ReadPointCloud(pcl_complete_filepath,pcl_obj_paulo); 
    %P.v = P.v(randperm(size(P.v,1)),:);
    ixs = randsample(1:size(P.v,1),min(max_pcl_length_for_ransac,size(P.v,1)));
    new_P.v = P.v(ixs,:);
    new_P.n = P.n(ixs,:);
    [~,~,inliers] = ransacfitplane(new_P.v',0.01,1);
    new_P.n(inliers,:)=[];
    new_P.v(inliers,:)=[];
    points2kinectply(new_P.v,new_pcl_complete_filepath);
end

