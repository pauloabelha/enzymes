% merge the many PCDs that compose one single pcl from the RGBD dataset
function [ P ] = RGBDDatasetMergePCDs( root_folder )
    
    pcl_filenames = FindAllFilesOfType( {'pcd'},root_folder);
    P.v = [];
    P.n = [];
    tot_toc = 0;
    for i=1:size(pcl_filenames,2)
        tic;
        P_pcd = ReadPointCloud([root_folder pcl_filenames{i}]);
        P.v = [P.v; P_pcd.v];
        P.n = [P.v; P_pcd.n];
        segms = {};
        segms{end+1}.v = P.v;
        segms{end}.n = P.n;
        P.segms = segms;
        tot_toc = tot_toc+toc;
        avg_toc = tot_toc/i;
        estimated_time_hours = (avg_toc*(size(pcl_filenames,2)-i))/(24*60*60);
        disp(['Estimated time to finish (HH:MM:SS): ' datestr(estimated_time_hours, 'HH:MM:SS')]);
    end
    PlotPCLSegments(P);
end

