function [ P ] = read_png_as_pclwithtable_myers2015( P )
    P.v = P.v(P.v(:,3)>10 & P.v(:,3) < 1000,:);
%     P.v(:,3) = P.v(:,3) - mean(P.v(:,3));
    [P, pcl_pca] = ApplyPCAPCl(P);
%     rot_y = GetRotMtx(pi,'y');
%     P = Apply3DTransfPCL({P},{rot_y});
    P.v = P.v(P.v(:,3)<=665,:); 
%     P.v = P.v(P.v(:,2)<=50,:); 
%     P = PointCloud(P.v);
%     P = ApplyPCAPCl(P,inv(pcl_pca));
    [P, pcl_pca] = ApplyPCAPCl(P);
    P.v = P.v - mean(P.v);
end
