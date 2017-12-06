function P = ReadPointCloud( filepath, min_n_pts_segm )    
    if ~exist('min_n_pts_segm','var')
        min_n_pts_segm = 0;
    end
    if ~exist('special_case','var')
        special_case='';
    end
    
    % Open file
    fid = fopen(filepath);
    if fid == -1
        error(['ERROR: could not open file "' filepath '"']);
    end
    
    if ischar(filepath)
        extension = filepath(end-2:end);
        switch extension
            case 'pcd'
                P = read_pcd( fid, min_n_pts_segm, filepath );
                P.f = [];
            case 'ply'
                P = read_ply( fid, min_n_pts_segm, filepath);
            case 'obj'
                P = read_obj( fid );
            case 'off'
                P = read_off( fid );
            case 'png'
                % read RGB-D as image then construct a point cloud from depth map
                P = read_png_as_pcl( fid );           
            otherwise
                error(['File extension (' extension ') not supported for reading point cloud (perhaps the path is missing the extension?)']);
        end
    else
        P = filepath;        
    end
    fclose(fid);
    CheckIsPointCloudStruct(P);
    P.filepath = filepath;
end

