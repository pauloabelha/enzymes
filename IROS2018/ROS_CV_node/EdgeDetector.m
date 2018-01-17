% Return the closest edge of P from point
function [ edges, min_dists, SQ ] = EdgeDetector( P, points, dump_edges, plot_fig, parallel)
    % print help
    if ischar(P) && P == "--help"
       disp('Function edge detector');        
       disp('This function will detect the closest edges of a point cloud for each point in a given list of points'); 
       disp('Only the first and second params are compulsory'); 
       disp([char(9) 'First param: filepath to the point cloud']); 
       disp([char(9) 'Second param: list of points passed in the followng syntax:']);
       disp([char(9) char(9) 'One point: "[0.1 0.1 0.1]"']);
       disp([char(9) char(9) 'Two point: "[0.1 0.1 0.1;0.2 0.2 0.2]"']);
       disp([char(9) char(9) 'Three point: "[0.1 0.1 0.1;0.2 0.2 0.2;0.3 0.3 0.3]"']);
       disp([char(9) char(9) 'The double quote around the list of points is required']);
       disp([char(9) 'Third param: 1 or 0 for whether to print the edges to the terminal (default is 1)']);
       disp([char(9) 'Fourth param: 1 or 0 for whether to plot the results (default is 0)']);
       disp([char(9) 'Fifth param: 1 or 0 for whether to run the superquadric fitting in parallel (default is 0)']);
       disp([char(9) char(9) 'Setting the parallel param to 1 may incur in a long waiting time to create a parallel pool of cores']);
       disp('')
       disp('Example calls:');
       disp([char(9) './edge_detector ~/ToolWeb/bowl_2_3dwh.ply "[0.1 0.1 0.1;0.2 0.2 0.2]" 0 1 0']);
       disp([char(9) 'This will cal edge_detector on the given point cloud, using two points, plot the results, and running serially']);
       disp('')
       disp('Example calls:');
       disp([char(9) './edge_detector ~/ToolWeb/bowl_2_3dwh.ply "[0.1 0.1 0.1;0.2 0.2 0.2;0.3 0.3 0.3]"']);
       disp([char(9) 'This will cal edge_detector on the given point cloud, using three points and print the edges to the terminal']);
       disp('')
       disp('Written by Paulo Abelha'); 
       edges = 0; min_dists = 0; SQ = 0;
       return;
    end
    %% check inputs
    try
        CheckIsPointCloudStruct(P);
    catch
        if ischar(P)
            P = ReadPointCloud(P);
        else
            PointCloud(P);
        end
    end
    try
        CheckNumericArraySize(points,[Inf 3]);
    catch
       % try to parse points string
       points_spilt = strsplit(points(2:end-1),';');
       points = zeros(numel(points_spilt),3);
       for i=1:numel(points_spilt)
           point_str = strsplit(points_spilt{i},' ');
           points(i,1) = s 	StupidMeshAlignment.mtr2double(point_str(1));
           points(i,2) = str2double(point_str(2));
           points(i,3) = str2double(point_str(3));
       end
    end
    %disp('Points:');
    %disp(points);
    %disp('');
    if ~exist('dump_edges','var') || dump_edges < 0
        dump_edges = 1;
    end  
    if ischar(dump_edges)
        dump_edges = str2double(dump_edges);
    end
    if ~exist('plot_fig','var') || plot_fig < 0  || (ischar(plot_fig) && str2double(plot_fig) < 0)
        plot_fig = 0;
    end
     if ~exist('parallel','var')
        parallel = 0;
     else
         parallel = str2double(parallel);
     end
     colours = {'.g', '.b', '.y', '.c'};
%     if ~exist('colours','var') || colours < 0 || (ischar(colours) && str2double(colours) < 0)
%         colours = {'.g', '.b', '.y', '.c'};
%     end          
    %% get SQ from pcl
    if plot_fig 
       clf; 
    end
% print help
SQ = PCL2SQ(P,4,plot_fig,0,parallel);
    if plot_fig 
        hold on;        
    end
    SQ = SQ{1};
    %% get superellipse pcl 
    pcl_superellipse = superellipse( SQ(1), SQ(2), SQ(5) );
    pcl_superellipse = [pcl_superellipse zeros(size(pcl_superellipse,1),1)];
    % rotate and translate pcl
    rot_mtx = GetEulRotMtx(SQ(6:8));    
    pcl_superellipse = [rot_mtx*pcl_superellipse']';
    pcl_superellipse = pcl_superellipse + SQ(end-2:end);
    pcl_superellipse(:,3) = pcl_superellipse(:,3) + SQ(3);    
    if plot_fig
        scatter3(pcl_superellipse(:,1),pcl_superellipse(:,2),pcl_superellipse(:,3),100,'.m');
    end
    %% calculate closest point
    dists = pdist2(pcl_superellipse,points);
    [min_dists,min_dist_ixs] = min(dists,[],1);    
    edges = pcl_superellipse(min_dist_ixs,:);
    for i=1:size(points,1)        
        if plot_fig
            scatter3(points(i,1),points(i,2),points(i,3),2000,colours{min(i,numel(colours))});
            scatter3(edges(i,1),edges(i,2),edges(i,3),2000,colours{min(i,numel(colours))});
        end
    end
    if plot_fig
        hold off;
    end
    if dump_edges
        disp('Edges:');
        disp(edges); 
    end
end

