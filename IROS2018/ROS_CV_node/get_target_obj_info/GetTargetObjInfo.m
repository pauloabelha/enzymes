% Return the closest edge of P from point
function [ edges, target_obj_align_vecs, min_dists, SQ ] = GetTargetObjInfo( P, points, task, verbose, pcl_downsampling, parallel)
    % print help
    if ischar(P) && P == "--help"
       disp('Function for geting target object info');        
       disp('This function will detect the closest edges of a point cloud for each point in a given list of points'); 
       disp('Only the first and second params are compulsory'); 
       disp([char(9) 'First param: filepath to the point cloud']); 
       disp([char(9) 'Second param: list of points passed in the followng syntax:']);
       disp([char(9) char(9) 'One point: "[0.1 0.1 0.1]"']);
       disp([char(9) char(9) 'Two points: "[0.1 0.1 0.1;0.2 0.2 0.2]"']);
       disp([char(9) char(9) 'Three points: "[0.1 0.1 0.1;0.2 0.2 0.2;0.3 0.3 0.3]"']);
       disp([char(9) char(9) 'The double quote around the list of points is required']);
       disp([char(9) 'Third param: task name (cutting, scooping or scraping)']);
       disp([char(9) 'Fourth param: 1 or 0 for whether to log the module''s behaviour and plot results']);
       disp([char(9) 'Fifth param: number of points to which downsample point cloud (defaults is 500). This gives a trade-off between efficiency and quality of superquadric fit.']);
       disp([char(9) 'Sixth param: 1 or 0 for whether to run the superquadric fitting in parallel (default is 0)']);
       disp([char(9) char(9) 'Setting the parallel param to 1 may incur in a long waiting time to create a parallel pool of cores']);
       disp('')
       disp('Example calls:');
       disp([char(9) './target_obj_info ~/ToolWeb/bowl_2_3dwh.ply "[0.1 0.1 0.1;0.2 0.2 0.2]" 1 0']);
       disp([char(9) 'This will call target_obj_info on the given point cloud, using two points, log and plot the results, and run serially']);
       disp('')
       disp('Example calls:');
       disp([char(9) './target_obj_info ~/ToolWeb/bowl_2_3dwh.ply "[0.1 0.1 0.1;0.2 0.2 0.2;0.3 0.3 0.3]"']);
       disp([char(9) 'This will call target_obj_info on the given point cloud, using three points and dump the info to the terminal, without log and plotting']);
       disp('')
       disp('Written by Paulo Abelha'); 
       edges = 0; min_dists = 0; SQ = 0; target_obj_align_vecs=0;
       return;
    end
    %% check inputs
    if ~exist('verbose','var')
        verbose = 0;
    else
        verbose = str2double(verbose);
    end
    % print inputs
    if verbose
        tic;
        disp('begin_log');
    end 
    % read pcl
    if verbose
        disp('Reading pcl...');
    end 
    try
        CheckIsPointCloudStruct(P);
    catch
        if ischar(P)
            P = ReadPointCloud(P);
        else
            PointCloud(P);
        end
    end
    if verbose
        toc;
    end
    % check points
    if verbose
        disp('Parsing input points...');
    end 
    try
        CheckNumericArraySize(points,[Inf 3]);
    catch
       % try to parse points string
       points_split = strsplit(points(2:end-1),';');
       points = zeros(numel(points_split),3);
       for i=1:numel(points_split)
            point_str = strsplit(points_split{i},' ');
            points(i,1) = str2double(point_str(1));
            points(i,2) = str2double(point_str(2));
            points(i,3) = str2double(point_str(3));
       end
    end
    if verbose
        toc;
    end    
    if ~exist('task','var')
        error('Please define a task name as third param');
    end
    if ~strcmp(task,'cutting') && ~strcmp(task,'scooping') && ~strcmp(task,'scraping')
        error(['Unknown task: ' task '. Acceptable tasks names are: cutting, scooping and scraping']);
    end
    if ~exist('pcl_downsampling','var')
        pcl_downsampling = 500;
    else
        pcl_downsampling = str2double(pcl_downsampling);
    end
    if ~exist('parallel','var')
        parallel = 0;
    else
        parallel = str2double(parallel);
    end
    if verbose
        disp('Inputs:');
        disp('Point cloud:');
        disp(P);
        disp('Points:');
        disp(points);
        disp('Verbose:');
        disp(verbose);
        disp('Point cloud downsampling to:');
        disp(pcl_downsampling);
        disp('Parallel:');
        disp(parallel);
    end  
    if parallel
        if verbose
            disp('Deleting previous parallel pool...');
        end
        delete(gcp('nocreate'));
        if verbose
            toc;
        end
        parpool;
        if verbose
            toc;
        end
    end
    if verbose
        disp(['Point cloud downsampled to ' num2str(pcl_downsampling) ' points']);
    end
    % fit superquadric
    if verbose
        disp('Fitting superquadric...');
    end
    SQs = cell(1,4);
    Es = zeros(1, 4);
    pca_pcl = pca(P.v);    
    R = DownsamplePCL(P, pcl_downsampling, 1);
    pcl = R.v*pca_pcl;
    inv_pca_pcl = inv(pca_pcl);
    [~, pcl_scale] = PCLBoundingBoxVolume( pcl );
    opt_options = optimset('Display','off','TolX',1e-10,'TolFun',1e-10,'MaxIter',1000,'MaxFunEvals',1000); 
    if parallel
        parfor i=1:4    
            [SQs{i}, ~, Es(i)] = FitSQToPCL_Paraboloid(pcl,pcl_scale,i,opt_options,[0 0 0 0 1],'');  
        end
    else
        for i=1:4    
            [SQs{i}, ~, Es(i)] = FitSQToPCL_Paraboloid(pcl,pcl_scale,i,opt_options,[0 0 0 0 1],''); 
            SQs{i}(end-2:end) = SQs{i}(end-2:end)*inv_pca_pcl;  
            SQs{i} = RotateSQWithRotMtx(SQs{i}, inv_pca_pcl');
        end
    end
    [~, b] = min(Es);
    SQ = SQs{b};
    if verbose
        toc;
    end
    if verbose 
        hold on;        
    end
    %% get superellipse pcl 
    pcl_superellipse = superellipse( SQ(1), SQ(2), SQ(5) );
    pcl_superellipse = [pcl_superellipse repmat(SQ(3),size(pcl_superellipse,1),1)];
    % rotate and translate pcl
    rot_mtx = GetEulRotMtx(SQ(6:8));    
    pcl_superellipse = [rot_mtx*pcl_superellipse']';
    pcl_superellipse = pcl_superellipse + SQ(end-2:end);
    if verbose
        scatter3(pcl_superellipse(:,1),pcl_superellipse(:,2),pcl_superellipse(:,3),100,'.m');
    end
    %% calculate closest point
    dists = pdist2(pcl_superellipse,points);
    [min_dists,min_dist_ixs] = min(dists,[],1);    
    edges = pcl_superellipse(min_dist_ixs,:);
    if verbose
        colours = {'.g', '.b', '.y', '.c'};
        for i=1:size(points,1)                
            scatter3(edges(i,1),edges(i,2),edges(i,3),2000,colours{min(i,numel(colours))});
            scatter3(points(i,1),points(i,2),points(i,3),2000,colours{min(i,numel(colours))});
        end
        hold off;
    end
    if verbose
        hold off;
    end
    target_obj_lid_point = SQ(end-2:end) + (GetSQVector(SQ)'.*SQ(3));
    target_obj_align_vecs = [repmat(target_obj_lid_point,size(edges,1),1) - edges]';
    disp('begin_target_obj_info');
       
    if strcmp(task, 'scraping')
        disp('target_obj_contact_points');
        disp(edges); 
        disp('target_obj_align_vecs');
        disp(target_obj_align_vecs');
    end
    
    if strcmp(task, 'scooping')
        disp('target_obj_contact_points');
        disp(target_obj_lid_point); 
        disp('target_obj_align_vecs');
        disp(-GetSQVector(SQ)');
    end
    disp('end_target_obj_info');

