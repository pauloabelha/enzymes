%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% By Paulo Abelha (p.abelha@abdn.ac.uk) 2017
%
%% Creates a point cloud (with normals) from a SQ
%   (SQ is short for superquadric/superparaboloid; pcl is short for point cloud)
% Please check paper LINK_TO_PAPER
% Inputs:
%   SQ - 1x15 array with SQ parameters
%   n_points - max number of points for the point cloud
%   plot_fig - whether to plot the pointcloud
%   verbose - whether to show info as funciton runs (default is false)%
% Outputs:
%   P - PointCloud struct (check function/"constructor" PointCloud)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ Ps ] = SQ2PCL( SQs, n_points, plot_fig )
    %% deal with list of SQs as input
    cell_input = 0;
    if iscell(SQs)
        cell_input = 1;
        temp = [];
        for i=1:size(SQs,2)
            if ~isempty(SQs{i})
                temp(end+1,:) = SQs{i};
            end
        end
        SQs = temp;
    end
    Ps = cell(1,size(SQs,1));
    for i=1:size(SQs,1)
        SQ = SQs(i,:);
        %% param checks
        if ~exist('SQ','var')
            error('This function needs a SQ as first param');
        end
        if ~exist('n_points','var')
            error('This function needs the number of points as second param');
        end
        CheckNumericArraySize(SQ,[1 15]);
        CheckIsScalar(n_points);
        if ~exist('plot_fig','var')
            plot_fig = 0;
        end
        %% deal with superparaboloids
        faces = [];
        if SQ(12) < 0
            [pcl, normals] = superparaboloid(SQ, n_points);
        else
            [pcl, normals, ~, ~, faces] = superellipsoid(SQ, n_points);    
        end   
        Ps{i} = PointCloud(pcl,normals,faces);        
    end
    %% plot
    if plot_fig
        PlotPCLS(Ps);
    end
    if ~cell_input
       Ps = Ps{1}; 
    end
end

