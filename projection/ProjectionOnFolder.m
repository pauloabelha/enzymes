function [ best_scores, best_categ_scores, accuracy_best, accuracy_categs, metric_1, pcl_gt_task_scores, pcl_filenames ] = ProjectionOnFolder( root_folder, task_name, use_segments, plot_fig )
    % default is not using the segments
    % ( 0 - do not consider segmentation
    %   1 - consider segmentation and projection
    %   2 - consider only segmentation)
    if ~exist('use_segments','var')
        use_segments = 0;
    end
    root_folder_ = root_folder;
    load([root_folder 'projection_data.mat']);
    root_folder = root_folder_;
    if ~exist('plot_fig','var')
        plot_fig = 0;
    else
        plot_fig_ = plot_fig;
    end    
    
    plot_fig = plot_fig_;
    
    pcl_filenames = FindAllFilesOfType( {'ply'}, root_folder );
    
    pcl_gt_task_scores = zeros(1,size(pcl_filenames,2));
    pcl_masses = zeros(1,size(pcl_filenames,2));
    tot_toc = 0;
    for i=1:size(pcl_filenames,2)  
        tic;
        pcl_shortname = GetPCLShortName( pcl_filenames{i} );
        for j=1:size(groundtruth,1)
            curr_pcl_filename = groundtruth{j,2};
            if strcmp(curr_pcl_filename, pcl_shortname)
                pcl_masses(i) = str2double(groundtruth{j,3});
                pcl_gt_task_scores(i) = str2double(groundtruth{j,4});
            end
        end
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(pcl_filenames,2)); 
    end
    
    best_scores = zeros(1,size(pcl_filenames,2));
    best_categ_scores = zeros(1,size(pcl_filenames,2));
    tot_toc = 0;
%     profile on;
    only_mass = 0;
    for i=1:size(pcl_filenames,2)
        tic;
        disp(['Projecting ' task_name ' onto folder ' root_folder '...']);
        P = ReadPointCloud([root_folder pcl_filenames{i}],50);
                    
            if only_mass
                best_scores(i) = feval(@TaskFunctionGPR, {gpr_onlymass,1}, pcl_masses(i));
            else
                dims_GPR = zeros(1,29);
                dims_GPR(1:26) = 1;
                best_scores(i) = SeedProjection( ideal_ptool, P, pcl_masses(i), task_name, @TaskFunctionGPR, {gpr_full,dims_GPR}, use_segments, plot_fig ); 
            end
%             best_scores(i) = round(best_scores(i),3);
            best_categ_scores(i) = TaskCategorisation(best_scores(i),task_name);
            disp(['Projection of ' task_name ' onto ' pcl_filenames{i} ' completed']);
            disp(['    Mass (' num2str(pcl_masses(i)) ') Scores: ' num2str(best_scores(i)) ' ' num2str(best_categ_scores(i)) ' (groundtruth: ' num2str(pcl_gt_task_scores(i)) ')']);

%             warning(['Could not project ' task_name ' onto ' pcl_filenames{i}]);
%             warning(E.message);

        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(pcl_filenames,2)); 
    end
%     profile viewer;
    disp('Finished projecting.');
    [accuracy_best,accuracy_categs,metric_1] = PlotTestResults( best_scores, best_categ_scores, pcl_gt_task_scores, pcl_filenames  );
    result_file_suffix = '';
    switch use_segments
        case 0
            result_file_suffix = '_nosegm';
        case 1
            result_file_suffix = '_withsegm';
        case 2
            result_file_suffix = '_onlysegm';
    end
    save([root_folder 'results' result_file_suffix]);
end

