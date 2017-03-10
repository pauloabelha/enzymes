function [ P, vol, scale,old_scale ] = RescalePcl( pcl_filepath, spec_scale_in, max_size_in, spec_size_in, write_file )
    if ~exist('write_file','var')
        write_file = 0;
    end
    % read pointcloud from file
    if ischar(pcl_filepath)
        P = ReadPointCloud(pcl_filepath,0);
    else
        P = pcl_filepath;
    end
    [ ~, old_scale ] = PCLBoundingBoxVolume( P.v );
    max_size = 0.5;
    if nargin == 2
        P.v = P.v/spec_scale_in;
        if min(min(P.f)) > 0
            P.f = P.f-1;
        end
        if write_file
            WritePly(P,strcat(pcl_filepath(1:end-4),'_rescaled.ply'));
            return;
        end
    end
    if nargin > 2
        max_size = max_size_in;
    end
    if nargin > 3
        spec_size = spec_size_in;
        prop = max(range(P.v))/spec_size;
        P.v = P.v/prop;       
    else
        % try to rescale pcl to according to max size (in meters)
        div_factor = 1.2;
        while max(range(P.v)) > max_size
            P.v = P.v/div_factor;
            for j=1:size(P.segms,2)
                P.segms{j}.v = P.segms{j}.v/div_factor;
            end
        end    
    end
    if write_file
        WritePly(P,strcat(pcl_filepath(1:end-4),'_rescaled.ply'));
    end
    [ vol, scale ] = PCLBoundingBoxVolume( P.v );
end

