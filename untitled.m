root_folder = '~/ToolArtec/';
pcl_filenames = FindAllFilesOfType({'ply'},root_folder);
tot_toc = 0;
% for i=1:size(pcl_filenames,1)
%     tic;
%     P = ReadPointCloud([root_folder pcl_filenames{i}]);
%     if isempty(P.n)
%        P.n = Get_Normals(P.v); 
%     end
%     P.u = [];
%     P.c = [];
%     P.segms = {};
%     WritePly(P,[root_folder pcl_filenames{i}]);
%     tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(pcl_filenames,1),['Removing segmentation ' root_folder pcl_filenames{i} '    ' ]);
% end
% 
% [ pcl_filenames ] = ApplyPCAToPCLFolder( root_folder );

n_pts = zeros(1,size(pcl_filenames,1));
n_faces = zeros(1,size(pcl_filenames,1));
tot_toc = 0;
for i=1:size(pcl_filenames,1)
    tic;
    P = ReadPointCloud([root_folder pcl_filenames{i}]);
    n_pts(i) = size(P.v,1);
    n_faces(i) = size(P.f,1);
    tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(pcl_filenames,1));
end