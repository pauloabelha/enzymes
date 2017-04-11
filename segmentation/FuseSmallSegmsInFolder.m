function [ problem_pcls, Es, n_pcls ] = FuseSmallSegmsInFolder( root_folder, pcl_file_ext )
    if ~exist('pcl_file_ext','var')
        pcl_file_ext = 'ply';
    end
    fused_folder = 'fused/';
    system(['mkdir ' root_folder fused_folder]);
    pcl_filenames = FindAllFilesOfType( {pcl_file_ext}, root_folder );
    n_pcls = numel(pcl_filenames);
    problem_pcls = {};
    Es = {};
    tot_toc = 0;
%     for i=1:n_pcls
%         if strcmp(pcl_filenames{i},'kitchenknife_2_out_6_10.ply')
%             break;
%         end
%     end
    for i=1:n_pcls
        try
            tic;
            P = ReadPointCloud([root_folder pcl_filenames{i}]);
            P = FuseSmallSegments(P);
            P = AddColourToSegms(P);
            WritePly(P,[root_folder fused_folder pcl_filenames{i}]);
            tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,n_pcls,['Fused ' pcl_filenames{i} ': ']);
        catch E
            problem_pcls{end+1} = pcl_filenames{i};
            Es{end+1} = E;
            disp(['Problem with pcl ' pcl_filenames{i}]);
        end
    end
    save([root_folder 'segm_fusion.mat']);
end

