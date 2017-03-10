function [ output_args ] = LoopProjectModel( model, task, pcl_filenames, n_proj, n_iter, plot, print_console, root_path, final_results_filepath, slash, str_split )
      %fprintf('model_ix:%d\n',model_ix);
    final_results_fid = fopen(final_results_filepath,'w+');
    if final_results_fid == -1
        error(strcat(['Could not open' final_results_filepath]));
    end

    fprintf(final_results_fid,'result_final');
    fprintf(final_results_fid,'\n');
    fprintf(final_results_fid,'model\t%s',model);
    fprintf(final_results_fid,'\n');
    fprintf(final_results_fid,'task\t%s',task);
    fprintf(final_results_fid,'\n');
    fprintf(final_results_fid,'n_proj\t%d',n_proj);
    fprintf(final_results_fid,'\n');
    fprintf(final_results_fid,'n_iter\t%d',n_iter);
    fprintf(final_results_fid,'\n');
    fprintf(final_results_fid,'\n');
    fprintf(final_results_fid,'SCORES:\tsize(part 1)\tproportion(part 1)\tfitting(part 1)\tsize(part 2)\tproportion(part 2)\tfitting(part 3)\tdistance\tangle Z axis\tangle center');
    fprintf(final_results_fid,'\n');

    path_results_folder = strcat([root_path slash 'results' slash]);

    read_results = {};
    for curr_pcl=1:size(pcl_filenames,2)
        %clearing the environment
        %close all Matlab subwindows 
        close all
        %clear Workspaces
        %clear all
        %clear
        %clear Command Window
        %clc
        
        %path to the directory containing the point clouds        
        pcl_filepath = strcat([root_path 'point_clouds' slash]);
        
        pcl_complete_filepath = strcat(pcl_filepath,pcl_filenames{curr_pcl});
        n_remove_plane_ransac = 0;
        max_pcl_length_for_ransac = 20000;

        print_fid = fopen(strcat([root_path slash 'results' slash 'dump_' model '_onto_' pcl_filenames{curr_pcl}(1:end-4) '.txt']),'w');
        if print_fid == -1
            error(strcat(['could not open' root_path slash 'results' slash 'dump_' model '_onto_' pcl_filenames{curr_pcl}(1:end-4) '.txt']));
        end        
        
        min_n_pts_segm = 50;
        max_n_points_per_segm = 2000;

        % [~,B] = plyread(pcl_complete_filepath,'tri');
        % pcl = B/1000;

        [P, segms_read] = ReadPointCloud(pcl_complete_filepath,min_n_pts_segm);

        %remove segments which are proportionately too small
        min_prop_segm_size = 20;
        segms = {};
        ix_new_segms=1;
        for i=1:size(segms_read,2)
            if size(segms_read{i}.v,1) >= size(P.v,1)/min_prop_segm_size
                segms{ix_new_segms} = segms_read{i};
                ix_new_segms=ix_new_segms+1;
            end
        end

        %segms = {segms{2} segms{3}};

        %check scale of vertices
        pcl_scale = 1;
        if range(P.v(:,1)) > 1    
            %scale is in milimiters; convert to meters
            pcl_scale = 1000;    
        end
        P.v = P.v/pcl_scale;

        %pca
        pcl = P.v;
        [A,~] = pca(pcl);
        pcl = pcl*A;
        pcl_normals = P.n;
        if ~isempty(P.n)
            pcl_normals = pcl_normals*A;
            clear A;
        end

        euler_angles_pca_segm = zeros(size(segms,2),3);
        for i=1:size(segms,2)
           [A,~] = pca(segms_read{i}.v);
           euler_angles_pca_segm(i,:) = rotm2eul_(A,'ZYZ');     
        end

        pcl_ransac = pcl;
        for i=1:n_remove_plane_ransac
            if size(pcl_ransac,1) >= 100
                ixs_downsample = randsample(1:size(pcl_ransac,1),min(max_pcl_length_for_ransac,size(pcl_ransac,1)));
                pcl_ransac = (pcl_ransac(ixs_downsample,:));
                [~,~,inliers] = ransacfitplane(pcl_ransac',0.0005,1);
                z_plane = pcl_ransac(inliers(1),3);
                %remove plane found by RANSAC
                pcl_ransac(inliers,:)=[];  
                %remove everything below the plane (possible because of prior PCA)
                pcl_ransac = pcl_ransac(pcl_ransac(:,3)>z_plane,:);
            end
        end
        pcl = pcl_ransac;

        %translate pcl so that every point has a positive value (this is to not
        %generate complex number when fitting function is making the (negative) value of a
        %point to the power of a non-integer value)
        %pcl = EnsureOnlyPositivePointPCL( pcl );

        ixs_downsample = randsample(1:size(pcl,1),min(max_n_points_per_segm,size(pcl,1)));
        pcl = pcl(ixs_downsample,:);
        if ~isempty(pcl_normals)
            pcl_normals = pcl_normals(ixs_downsample,:);
        end
        if isempty(segms)
            segms{1}.v = pcl;
            segms{1}.n = pcl_normals;
        else
            for i=1:size(segms,2)                
                segms{i}.v = segms{i}.v(randsample(1:size(segms{i}.v,1),min(max_n_points_per_segm,size(segms{i}.v,1))),:);
            end
        end
        
        %remove outlier points from segments
        for i=1:size(segms,2)     
            min_value = median(segms{i}.v)-4*std(segms{i}.v);
            max_value = median(segms{i}.v)+4*std(segms{i}.v);
            for dim=1:3                
                segms{i}.v = segms{i}.v(segms{i}.v(:,dim)<max_value(dim),:);
                segms{i}.v = segms{i}.v(segms{i}.v(:,dim)>min_value(dim),:);
            end
        end       
        
        pcls = InitializeSegmentationModePCL( min_n_pts_segm, {}, segms, 2, [], [Inf Inf Inf Inf], [Inf Inf Inf Inf] );

        tic
        [results, ~] = ProjectModel( model, task, n_proj, n_iter, pcls, plot, print_fid, print_console, euler_angles_pca_segm );
        Print('Total time elapsed: %f',toc,print_fid,print_console);        
        
        result_fid = WriteResults( model, task, pcl_filenames{curr_pcl}, n_proj, n_iter, results, path_results_folder );
        read_result = ReadResult( str_split, result_fid );
        fclose(result_fid);
        WriteClusteredResults( model, task, pcl_filenames{curr_pcl}, n_proj, n_iter, read_result, path_results_folder );       
        fclose(print_fid);
        WriteExcelResult( final_results_fid, read_result );
        read_results{end+1} = read_result;
    end    
    fclose(final_results_fid);
end