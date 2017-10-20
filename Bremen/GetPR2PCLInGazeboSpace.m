function [ P ] = GetPR2PCLInGazeboSpace( root_folder, pcl_filename, base2kinect_eul_rad, base2kinect_transl )
    table_height = 0.75;
    max_target_obj_height = 0.3;
    max_height = 0.9;
    max_dist = 0.65;
    P = ReadPointCloud([root_folder pcl_filename]);
    r = GetEulRotMtx(base2kinect_eul_rad,{'x', 'y', 'z'});    
    Q = Apply3DTransfPCL(P,r);
    pcl = Q.v;
    pcl = pcl + repmat(base2kinect_transl,size(pcl,1),1);
    pcl = pcl(pcl(:,1)<=max_dist,:);
    pcl = pcl(pcl(:,2)<=max_dist,:);
    pcl = pcl(pcl(:,3)>=table_height & pcl(:,3) <= table_height+max_target_obj_height,:);    
    P = PointCloud(pcl);
    WritePly(P,[root_folder pcl_filename(1:end-4) '.ply']);
end

