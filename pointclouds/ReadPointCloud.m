function P = ReadPointCloud( filepath, min_n_pts_segm )    
    if ~exist('min_n_pts_segm','var')
        min_n_pts_segm = 0;
    end
    if ~exist('special_case','var')
        special_case='';
    end
    if ischar(filepath)
        extension = filepath(end-2:end);
        switch extension
            case 'pcd'
                P = read_pcd( filepath, min_n_pts_segm );
                P.f = [];
            case 'ply'
                P = read_ply( filepath, min_n_pts_segm);
            case 'obj'
                P = read_obj( filepath );
            case 'png'
                % read RGB-D as image then construct a point cloud from depth map
                P = read_png_as_pcl( filepath );           
            otherwise
                error(['File extension (' extension ') not supported for reading point cloud (perhaps the path is missing the extension?)']);
        end
    else
        P = filepath;        
    end
    CheckIsPointCloudStruct(P);
end

