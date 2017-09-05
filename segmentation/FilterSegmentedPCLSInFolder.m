function [ problem_pcls, E_SEGMS ] = FilterSegmentedPCLSInFolder( root_folder, min_error, pcl_file_ext )
    MAX_N_SEGMS = 4;
    if exist('min_error','var')
        MIN_SEGM_ERROR = min_error;
    else
        MIN_SEGM_ERROR = 0.5;
    end
    if ~exist('pcl_file_ext','var')
        pcl_file_ext = 'ply';
    end
    pcl_filenames = FindAllFilesOfType( {pcl_file_ext}, root_folder );
    n_pcls = numel(pcl_filenames);
    TOT_ERRORS = zeros(n_pcls,1);
    E_SEGMS = cell(1,n_pcls);
    good_segm_folder = ['good_segmentations_' num2str(MIN_SEGM_ERROR) '/'];
    disp(['mkdir ' root_folder good_segm_folder]);
    system(['mkdir ' root_folder good_segm_folder]);    
    prev_pcl_prefix_name = '';
    n_good_segmentations = 0;
    n_unique_segmentations = 0;
    tot_toc = 0;
%     for k=1:n_pcls
%         if strcmp(pcl_filenames{k}, 'hammer_9_out_7_10.ply')
%             break;
%         end
%     end
    k=1;
    problem_pcls = {};
    tot_toc = 0;
    for i=k:n_pcls
        tic;
        try
            tic;
            P = ReadPointCloud([root_folder pcl_filenames{i}]);
            pcl_prefix_name = strsplit( pcl_filenames{i},'_out_');
            pcl_prefix_name = pcl_prefix_name{1};
%             if strcmp(pcl_prefix_name,prev_pcl_prefix_name)
%                 segm_diff = sum(P.u == prev_P.u)/size(P.u,1);
%                 disp(['Segmentation similarity of ' pcl_filenames{i} ' and ' pcl_filenames{i-1} ': ' num2str(segm_diff)]);
%                 if segm_diff > 0.95
%                     disp('Skipping similar segmentation (> 95% similar)');
%                     continue;
%                 else
%                    n_unique_segmentations = n_unique_segmentations + 1;
%                 end
%             end 
%             prev_P = P;
            P = DownsamplePCL(P,1000);
            if numel(P.segms) <= MAX_N_SEGMS
                disp(['Fitting SQs to ' pcl_filenames{i} '...']);
                [ SQs, ~, E_SEGM ] = PCL2SQ( P, 2 );
                E_SEGMS{i} = E_SEGM;
                disp(['Fitted SQs errors (min=' num2str(MIN_SEGM_ERROR) '): ' num2str(E_SEGM)]);
                good_segm_ixs = E_SEGM <= MIN_SEGM_ERROR;
                if all(good_segm_ixs)
                    n_good_segmentations = n_good_segmentations + 1;
                    disp(['Found good segmentation! ' pcl_filenames{i} ' with ' num2str(numel(E_SEGM)) ' segments']);
                    system(['cp ' root_folder pcl_filenames{i} ' ' root_folder good_segm_folder pcl_filenames{i}]);
                end
            end
%             disp(['Proportion of unique segmentations: ' num2str(n_unique_segmentations/i)]);
            disp(['Proportion of good segmentations: ' num2str(n_good_segmentations/i)]);
            prev_pcl_prefix_name = pcl_prefix_name;        
            tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,n_pcls,['Filtering segmented pcls ' pcl_filenames{i} ' ' num2str(numel(P.segms)) ' segms: ']);
        catch
            disp(['ERROR with pointcloud ' pcl_filenames{i}]);
            problem_pcls{end+1} = pcl_filenames{i};
            continue; 
        end
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,n_pcls);
    end    
end