function [SH] = GET_SH_PCL(pcl_points, normals)
%GET_SH_PCL Returns the shape histogram for the supplied pcl and normals
SQ_SH_PARAMS = CalculateSH(pcl_points, normals, 0);
% hist3(SQ_SH_PARAMS,[40 40]);
% xlabel('Distance'); 
% ylabel('Angle');

end

