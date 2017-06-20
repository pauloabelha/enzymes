function PlotPCLS( Ps, downsample, single_colour, colours )    
%     figure;
    hold on;
    if ~exist('downsample','var') || downsample <= 0
        downsample = Inf;
    end
    if ~exist('single_colour','var')
        single_colour = 0;
    end
    if ~exist('colours','var')
        colours = {'y' '.r' '.g' '.b'}; 
    end
    
    if~iscell(Ps)
        CheckIsPointCloudStruct(Ps);
        Ps = {Ps};
    end
    
    for i=1:size(Ps,2)
        if isempty(Ps{i}) || (isfield(Ps{i},'v') && isempty(Ps{i}.v))
            warning('Skipping empty point cloud');
            continue;
        end
        if isstruct(Ps{i})
            P = Ps{i};
        elseif ismatrix(Ps{i})
            P = PointCloud(Ps{i});
        end
        if isempty(P.v)
            warning('Skipping empty point cloud');
        else
            P = DownsamplePCL(Ps{i},downsample);
            try
                CheckIsPointCloudStruct(P);
            catch
                P = PointCloud(P);
                CheckIsPointCloudStruct(P);
            end
            if single_colour
                colour = '.k';
            else
                colour = colours{mod(i,numel(colours))+1};
            end
            scatter3(P.v(:,1),P.v(:,2),P.v(:,3),100,colour); axis equal;
        end
    end
    hold off;
end
