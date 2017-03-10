function [ P, G ] = PointCloud2GazeboMesh( pcl_filepath, material, downsample, R, calc_faces_in )
    calc_faces = 0;
    if nargin > 3
        calc_faces = calc_faces_in;
    end
    % read pointcloud from file
    [P,segms] = ReadPointCloud(pcl_filepath,0);
    if nargin > 2
        P.f = [];
        P.u = [];
        prop = min(1,downsample/size(P.v,1));
        [P.v, pcl_ixs] = DownsamplePCL(P.v,downsample);              
        sum_segms_points = 0;
        for i=1:size(segms,2)
            sum_segms_points = sum_segms_points + round(prop*size(segms{i}.v,1));
            [segms{i}.v, ~] = DownsamplePCL(segms{i}.v,round(prop*size(segms{i}.v,1)));
            segms{i}.n = Get_Normals(segms{i}.v);
        end
        if sum_segms_points > size(P.v,1)
            segms{end}.v = segms{end}.v(1:size(segms{end}.v,1)-(sum_segms_points-size(P.v,1)),:);
        else
            P.v = P.v(1:sum_segms_points,:);
            P.n = P.n(1:sum_segms_points,:);
        end
    end   
    
    % get normals for the pcl 
    if isempty(P.n)
        P.n = Get_Normals(P.v);
    else
        P.n = P.n(pcl_ixs,:);
    end  
    % try to rescale pcl to meters
    while max(range(P.v)) > 0.5
        P.v = P.v/2;
    end
    for i=1:size(segms,2)
        while max(range(segms{i}.v)) > 0.5
            segms{i}.v = segms{i}.v/2;
        end
    end    
    % reorient the mesh with PCA
    pca_ = pca(P.v);
    P.v = P.v*pca_;
    P.n = P.n*pca_;
    for i=1:size(segms,2)
        segms{i}.v = segms{i}.v*pca_;
        if ~isempty(segms{i}.n)
            segms{i}.n = segms{i}.n*pca_;
        end       
    end    
    if nargin > 3
        P.v = ApplyTransformations(P.v,{'normal', R});
        P.n = ApplyTransformations(P.n,{'normal', R});
        for i=1:size(segms,2)
            segms{i}.v = ApplyTransformations(segms{i}.v,{'normal', R});
            segms{i}.n = ApplyTransformations(segms{i}.n,{'normal', R});
        end
    end 
    %move centroid of mesh to the origin
    [~, centroid] = kmeans(P.v,1);
    %rotate and translate grid
    T = [eye(3) -centroid'; 0 0 0 1];
    pcl = [P.v ones(size(P.v ,1),1)];
    pcl = (T*pcl')';
    P.v = pcl(:,1:3);
    for i=1:size(segms,2)
        pcl = [segms{i}.v ones(size(segms{i}.v ,1),1)];
        pcl = (T*pcl')';
        segms{i}.v = pcl(:,1:3);
    end
    %move mesh to be just above the ground
    P.v(:,3) = P.v(:,3) - min(P.v(:,3));
    % perform an SQ fitting on each segment
    [SQs]=PCL2SQ(segms,1,0,0,[1 1 1 0 1]);   
    % get faces if not provided
    if isempty(P.f) && calc_faces
        [P.v,P.f]=SQsToPCL({},segms,0); 
    end
    % ensure that faces are 0-indexed
    if sum(min(P.f)) >= size(P.f,2)
        P.f = P.f - 1;
    end          
    % get Gazebo physical values
    [ G.inertia, ~, G.mass, G.density ] = CalcCompositeMomentInertia(SQs,P.v,material);  
    % get center of mass
    [~,G.center_mass]=kmeans(P.v,1);
    for i=1:3
        if G.center_mass(i) < 0.001
            G.center_mass(i) = 0;
        end
    end
    dlmwrite(strcat(pcl_filepath(1:end-4),'_gazebo.txt'),[G.inertia; G.center_mass; [0 G.mass G.density]]);
    WritePly(P,strcat(pcl_filepath(1:end-4),'_gazebo.ply'));   
end

