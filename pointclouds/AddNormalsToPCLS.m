function AddNormalsToPCLS( root_folder, birds_eye_viewpoint )
    if ~exist('birds_eye_viewpoint','var')
        birds_eye_viewpoint = 0;
    end
    % get the name of every pcl in the root folder
    pcl_filenames = FindAllFilesOfType( {'ply'}, root_folder );
    tot_toc = 0;
    for i=1:size(pcl_filenames,2)
        tic
        try
            P = ReadPointCloud([root_folder pcl_filenames{i}]);
            if min(min(P.f)) > 0
                P.f = P.f - 1;
            end
            P.n = Get_Normals(P.v);
            if birds_eye_viewpoint
                P.n(P.n(:,3)<-0.02,:) = abs(P.n(P.n(:,3)<-0.02,:));
            end
            WritePly(P,[root_folder pcl_filenames{i}]);
            disp([root_folder pcl_filenames{i}]);
            tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(pcl_filenames,2));
        catch E
            warning(E.message);
        end
    end

end

