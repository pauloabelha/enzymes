


function [ P ] = RemovePlaneRansac( root_folder, pcl_filename, plane_thickness, output_type )    
    %% constants
    % min and max plane thickness (in meters)
    MIN_PLANE_THICKNESS = 0.001;
    MAX_PLANE_THICKNESS = 1;
    DEFAULT_PLANE_THICKNESS = 0.005;
    % default folder to write is Desktop
    DEFAULT_ROOT_FOLDER = '~/Desktop/';
    %% check inputs
    % set whether to write
    % either read the pcl or get it form the first input
    matrix_output = 0;
    if isstruct(root_folder)        
        P = root_folder;
        CheckIsPointCloudStruct(P);
        root_folder = DEFAULT_ROOT_FOLDER;
    else
        try
            CheckNumericArraySize(root_folder,[Inf 3]);
            matrix_output = 1;
            P = PointCloud(root_folder);
        catch
            CheckIsChar(root_folder);
            CheckIsChar(pcl_filename);
            P = ReadPointCloud([root_folder pcl_filename],100); 
        end               
    end
    % check if default plane thickness is required
    if ~exist('plane_thickness','var')
       plane_thickness = DEFAULT_PLANE_THICKNESS; 
    end
    % check plane thickness
    CheckScalarInRange(plane_thickness,'closed-closed',[MIN_PLANE_THICKNESS MAX_PLANE_THICKNESS]);
    % set whether to write resulting pcl
    if ~exist('output_type','var')
        write_output = 0;
    else
        write_output = 1;
    end
    %% rescale pcl to be in meters
       
    % try to convert pcl scale to meters
    P = RescalePcl(P,0,3);
    %% get downsampled pcl to work with
    % downsample pcl if too big
    MAX_PCL_SIZE = 2e4;
    P_ds = DownsamplePCL(P,MAX_PCL_SIZE,1);    
    % remove previous segmentation form the pcl
    P.segms = {}; 
    %% apply PCA to try aligning the pcl with the X-Y-Z axis
    pcl_pca = pca(P.v);
    P_ds.v = P_ds.v*pcl_pca;
    if isfield(P,'n') && ~isempty(P_ds.n)
        P_ds.n = P_ds.n*pcl_pca;
    end
    P.v = P.v*pcl_pca;
    %% apply RANSAC for plane fitting and get index for points above plane
    % run RANSAC to fit a plane on downsampled pcl
    [~,M,~] = ransacfitplane(P_ds.v',plane_thickness,1);
    %get the inliers to the plane
    [inliers, ~] = feval(@planeptdist, M, P.v', plane_thickness);    
    % remove everything below the plane (possible because of prior PCA)
    z_plane = P.v(inliers,3);   
    ixs_above_plane = P.v(:,3)>=mean(z_plane)+plane_thickness;
    %% get pcl above plane
    P = GetIndexedPointCloud( P, ixs_above_plane');  
    %% recover faces from original pcl
    % HAS BUGS - % to be re-implemented
%     inliers = ~ixs_above_plane;
% 
%     n = 1;
%     ix_in = 1;
%     pt = 0;  
%     outliers_faces = {};    
%     ceil_n_inliers=0;
%     if ~isempty(inliers)
%         ceil_n_inliers = ceil(inliers(end)/3);
%     end
%     for i=1:ceil_n_inliers
%         valid_face = 1;
%         for j=1:3
%             if n==inliers(ix_in)
%                 valid_face = 0;
%                 ix_in=ix_in+1;
%             else
%                 pt=pt+1;
%             end
%             n=n+1;
%         end
%         if valid_face
%             outliers_faces{end+1} = [pt-2 pt-1 pt];
%         end        
%     end
%     pt=pt+1;
%     n_pts = size(P.v,1);
%     while mod((n_pts-pt)+1,3) ~= 0
%         n_pts=n_pts-1;
%     end
%     extra_faces = reshape(pt:n_pts,3,ceil((n_pts-pt)/3))';
%     
%     faces = zeros(size(outliers_faces,2)+size(extra_faces,1),3);
%     for i=1:size(outliers_faces,2)
%         faces(i,:) = outliers_faces{i};
%     end
%     faces(size(outliers_faces,2)+1:end,:) = extra_faces;
%     P.f = faces;
    
    P.segms{end+1}.v = P.v;
    P.segms{end}.n = P.n;
    
    if write_output
        % remove extension form pcl filename
        if size(pcl_filename,2) > 4
            pcl_filename = pcl_filename(1:end-4);
        end
        pcl_full_filepath = [root_folder pcl_filename  '_noplane.'];
        WritePly( P, [pcl_full_filepath output_type]);
        disp(['Point cloud written to ' pcl_full_filepath output_type]);
    end
    
    if matrix_output
        P = P.v;
    end
end

%------------------------------------------------------------------------
% Function to calculate distances between a plane and a an array of points.
% The plane is defined by a 3x3 matrix, P.  The three columns of P defining
% three points that are within the plane.

function [inliers, P] = planeptdist(P, X, t)
    
    n = cross(P(:,2)-P(:,1), P(:,3)-P(:,1)); % Plane normal.
    n = n/norm(n);                           % Make it a unit vector.
    
    npts = length(X);
    d = zeros(npts,1);   % d will be an array of distance values.

    % The following loop builds up the dot product between a vector from P(:,1)
    % to every X(:,i) with the unit plane normal.  This will be the
    % perpendicular distance from the plane for each point
    for i=1:3
        d = d + (X(i,:)'-P(i,1))*n(i); 
    end
    
    inliers = find(abs(d) < t);
end

