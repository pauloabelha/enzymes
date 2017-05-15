function ConvertPointCloud( root_folder, pcl_filename, ext_out )
    try
        P = ReadPointCloud([root_folder pcl_filename]);
        if min(min(P.f)) > 0
           P.f = P.f - 1;
        end    
        if ~isempty(P.segms)
            P = AddColourToSegms(P); 
        end
        if strcmp(ext_out,'pcd')
            WritePcd(P,[root_folder pcl_filename(1:end-3) ext_out]);
        end
        if strcmp(ext_out,'ply')
            WritePly(P,[root_folder pcl_filename(1:end-3) ext_out]);
        end        
    catch E
        warning(E.message);
        warning(['Could not convert pointcloud ' pcl_filename]);
    end
end

