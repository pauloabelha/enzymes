function [problematic_pcls] = CheckScaleInertiaPCLs(root_folder)
    MAX_RANGE_P = 0.5;
    DEFAULT_MASS = 0.1;
    pcl_filenames = FindAllFilesOfType({'ply'},root_folder);
    problematic_pcls = {};
    tot_toc = 0;
    max_sizes = zeros(1,size(pcl_filenames,2));
    for i=1:size(pcl_filenames,1)
        tic;
        disp(['Reading point cloud... ' [root_folder pcl_filenames{i}]]);
        P = ReadPointCloud([root_folder pcl_filenames{i}]);
        range_P = range(P.v);
        if max(range_P) > MAX_RANGE_P
            problematic_pcls{end+1} = P.filepath;
            disp([char(9) 'Problems with pcl: ' P.filepath]);
            disp([char(9) 'Skipping inertia calculation and going to next point cloud']);
        else
            disp([char(9) 'Scale: ' num2str(range_P)]);
            disp([char(9) 'Calculating moment of inertia...']);
            [ ~, ~, inertial ] = CalcCompositeMomentInertia( P, DEFAULT_MASS);        
            disp([char(9) 'Intertial ([centre of mass inertia diagonal): ' num2str(inertial)]);
        end
        tot_toc = DisplayEstimatedTimeOfLoop( tot_toc+toc, i, size(pcl_filenames,1));
    end


end

