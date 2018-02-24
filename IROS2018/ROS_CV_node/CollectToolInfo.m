function [affordance_scores, problematic_pcls] = CollectToolInfo(pcl_root_folder, task_function_root_folder, task)
    masses = ReadCSVGeneric([pcl_root_folder 'masses']);
    pcl_filenames = FindAllFilesOfType({'ply'}, pcl_root_folder);
    tot_toc_i = 0;
    gpr_task_path = [task_function_root_folder 'IROS2018_TaskFunction_' task '.mat'];
    N_TRIES = 10;
    problematic_pcls = {};
    affordance_scores = zeros(size(pcl_filenames,1), N_TRIES);
    error_msgs = {};
    
    SQs_origs = cell(1, size(pcl_filenames,1));
    best_ptools = zeros(size(pcl_filenames,1), 25);
    grasp_centres = zeros(size(pcl_filenames,1), 3);
    action_centres = grasp_centres;
    tool_tips = grasp_centres;
    tool_heels = grasp_centres;
    tool_quaternions = zeros(size(pcl_filenames, 1), 4);
    
    for i=1:size(pcl_filenames,1)
        pcl_filepath = [pcl_root_folder pcl_filenames{i}];
        tic_i = tic;
        disp(['Point cloud: ' pcl_filepath]);
        disp([char(9) 'Reading point cloud...']);
        pcl_mass = str2double(masses{i,2});
        target_obj_align_vec = [0;0;1];
        target_obj_contact_point = [0 0 0];
        try
            tot_toc_j = 0;
            for j=1:N_TRIES
                tic_j = tic;
                disp([char(9) char(9) 'Tryout loop: #:' char(9) num2str(j)]);
                [ ~, SQs_origs{i}, best_ptools(i, :), grasp_centres(i, :), action_centres(i, :), tool_tips(i, :), tool_heels(i, :), tool_quaternions(i,:), affordance_scores(i, j) ] = GetToolInfo( pcl_filepath, pcl_mass, target_obj_align_vec, target_obj_contact_point, task, gpr_task_path, 0, 1 );
                disp([char(9) char(9) 'Affordance score: ' char(9) num2str(affordance_scores(i, j))]);
                tot_toc_j = DisplayEstimatedTimeOfLoop(tot_toc_j+toc(tic_j),j,N_TRIES, [char(9) 'Tryouts loop: ']);
            end
        catch E
            affordance_scores(i, j:end) = -1;
            disp([char(9) E.message]);
            problematic_pcls{end+1} = pcl_filepath;
            error_msgs{end+1} = E.message;
        end
        tot_toc_i = DisplayEstimatedTimeOfLoop(tot_toc_i+toc(tic_i),i,size(pcl_filenames,1),'Point clouds loop: ');        
    end
    save([pcl_root_folder 'all_tools_info_' GetFileSuffixCurrentTime() '.mat']);
end

