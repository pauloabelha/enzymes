% This function will apply PCA to (and centralise) every PCL
% in a given folder and save them with the same name
% it is also possible to define a list of extensions for the PCLS
function [ pcl_filenames ] = ApplyPCAToPCLFolder( root_folder, output_folder, exts )
    CheckIsChar(root_folder);
    if ~exist('ext','var')
        exts = {'ply'};
    end
    if ~exist('output_folder','var')
        output_folder = '';
    end
    pcl_filenames = FindAllFilesOfType(exts,root_folder);
    tot_toc = 0;
    for i=1:size(pcl_filenames,2)
        tic;
        P = ReadPointCloud([root_folder pcl_filenames{i}]);
        P = ApplyPCAPCl(P);
        mean_v = mean(P.v);
        P.v = P.v - mean_v;
        for j=1:numel(P.segms)
            P.segms{j}.v = P.segms{j}.v - mean_v;
        end
        if max(max(P.f)) >= size(P.v,1)
            P.f = P.f - 1;
        end
        WritePly(P,[root_folder output_folder pcl_filenames{i}]);
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(pcl_filenames,2),['Applying PCA to folder: ' root_folder pcl_filenames{i} '    ' ]);
        
    end
end

