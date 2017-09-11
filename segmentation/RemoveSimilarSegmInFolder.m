function [ output_path, prop_diff_segm ] = RemoveSimilarSegmInFolder( root_folder, pcl_file_ext, MIN_SCORE_SIM )
    if ~exist('MIN_SCORE_SIM','var')
        MIN_SCORE_SIM = 0.9;
    end
    if ~exist('pcl_file_ext','var')
        pcl_file_ext = 'ply';
    end
    pcl_filenames = FindAllFilesOfType( {pcl_file_ext}, root_folder );
    n_pcls = numel(pcl_filenames);
    unique_segm_folder = ['unique_segmentations_' num2str(MIN_SCORE_SIM) '/'];
    output_path = [root_folder unique_segm_folder];
    system(['mkdir ' output_path]);
    %% first iteration for the first pcl (same as if found a new segmentation)
    % the first pcl is always a new segmentation
    i = 1;
    prev_pcl_prefix_name = strsplit( pcl_filenames{i},'_out_');
    prev_pcl_prefix_name = prev_pcl_prefix_name{1};
    P_curr = ReadPointCloud([root_folder pcl_filenames{i}]);
    %[P_curr, downsample_ixs] = DownsamplePCL(P_curr,1000);
    %P_curr = PointCloud(P_curr.v,[],[],P_curr.u);
    %P_curr = FuseSmallSegments(P_curr);
    prev_curr_n_segms = numel(P_curr.segms);
    prev_curr_labels = P_curr.u;
    clear P_curr;    
    system(['cp ' root_folder pcl_filenames{i} ' ' root_folder unique_segm_folder pcl_filenames{i}]); 
    set_prev_names{1} = pcl_filenames{i};
    set_prev_n_segms{1} = prev_curr_n_segms;
    set_prev_segm_labels{1} = GetEquivalentLabels(prev_curr_labels);
    %% from the second pcl on
    prop_diff_segm = zeros(1,n_pcls);
    prop_diff_segm(1) = 1;
    n_diff_segm = 1;    
    tot_toc = 0;
    for i=2:n_pcls
        tic;
        prop_diff_segm(i) = n_diff_segm/i;
        disp(['Proportion of different segmentations: ' num2str(prop_diff_segm(i))]);
        % get current pcl prefix name
        pcl_prefix_name = strsplit( pcl_filenames{i},'_out_');
        pcl_prefix_name = pcl_prefix_name{1};        
        P_curr = ReadPointCloud([root_folder pcl_filenames{i}]);
        %% if found a different pcl, restart segmentation set of labels
        % and the downsampling indexes
        if  ~strcmp(pcl_prefix_name,prev_pcl_prefix_name)
            set_prev_segm_labels = {};
            set_prev_n_segms = {};
            %[P_curr, downsample_ixs] = DownsamplePCL(P_curr,1000);
%         else
%             P_curr.v = P_curr.v(downsample_ixs,:);
%             P_curr.u = P_curr.u(downsample_ixs,:);
        end
        % fuse small segments
        %disp('        Fusing small segments...');        
        %P_curr = PointCloud(P_curr.v,[],[],P_curr.u);
        %P_curr = FuseSmallSegments(P_curr);  
        curr_n_segms = numel(P_curr.segms);        
        curr_labels = GetEquivalentLabels(P_curr.u);
        % disp pcl info
        disp([pcl_filenames{i} ': ' num2str(curr_n_segms)]);        
        clear P_curr;        
        
        %% check for new segmentation
        found_similar_segm = 0;
        disp(['        Going through current set size: ' num2str(numel(set_prev_segm_labels))]);
        for j=1:numel(set_prev_segm_labels)
            if curr_n_segms == set_prev_n_segms{j}
                disp(['                Same number of segments: ' num2str(curr_n_segms) ' ' num2str(set_prev_n_segms{j})]);
                ixs_sim = curr_labels == set_prev_segm_labels{j};
                sim_score = sum(ixs_sim)/size(ixs_sim,1);
                disp(['                Similarity score: ' num2str(sim_score)]);
                if sim_score >= MIN_SCORE_SIM
                    disp(['                Found similar segmentation for ' pcl_filenames{i} ' and ' set_prev_names{j}]);
                    found_similar_segm = 1;
                    break;
                end
            else
               disp(['                Different number of segments: ' num2str(curr_n_segms) ' ' num2str(set_prev_n_segms{j})]);
            end
        end
        %% if a new segmentation was found, copy pcl and modify set
        if ~found_similar_segm
            n_diff_segm = n_diff_segm + 1;
            % copy pcl
            disp(['        New segmenttion found. Copying pointcloud ' pcl_filenames{i}]);
            system(['cp ' root_folder pcl_filenames{i} ' ' root_folder unique_segm_folder pcl_filenames{i}]);            
            % modify set
            set_prev_names{end+1} = pcl_filenames{i};
            set_prev_n_segms{end+1} = curr_n_segms;
            set_prev_segm_labels{end+1} = curr_labels;                
        end
        prev_pcl_prefix_name = pcl_prefix_name; 
        prev_pcl_filename = pcl_filenames{i};
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,n_pcls);
    end    
end

function u_eq = GetEquivalentLabels(u_in)
    u_unique = unique(u_in,'stable');
    u_eq = u_in;
    for i=1:numel(u_unique)
        u_eq(u_in==u_unique(i)) = i;
    end
end




