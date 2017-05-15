function [ task, tools, failed_tool_ptool_ixs, all_tool_scores, best_ptool_scores, best_ptools_ixs ] = ReadClusterCalibrationResults( root_folder, task, dataset_folder, extracted_ptools_filename, backup_file_suffix )
    if ~exist('backup_file_suffix','var')
        backup_file_suffix = '';
    end    
    FILE_PREFIX='output_cluster_training';
    res_folder = [root_folder task '/'];
    filenames = FindAllFilesOfPrefix( FILE_PREFIX, res_folder );
    if isempty(filenames)
        error(['Could not find any files with prefix ''' FILE_PREFIX ''' at ' res_folder]);
    end
    filenames = SortFileNames(filenames);    
    %% end of file indicator
    EOF_INIDICATOR = 'end_calibration';
    %% initialise variables
    tool_scores = {};
    n_failed_sim = 0;
    tot_n_sim = 0;
    failed_tool_ptool_ixs = [];
    all_tool_scores = [];
    best_ptools_ixs = [];
    best_ptool_scores = [];
    for f=1:numel(filenames)
        output_filepath = [res_folder filenames{f}];
        try
            fid_output = fopen(output_filepath);
        catch
            error(['Could not open file ' output_filepath ' - are you mising the extension in the filename?']);
        end
        if fid_output == -1
            error(['Could not open file ' output_filepath ' - are you mising the extension in the filename?']);
        end
        %% read task name
        task = get_task(fgetl(fid_output));
        line = fgetl(fid_output);
        % n_trials = get_n_trials(line);
        %% read values
        line = fgetl(fid_output);
        line_first = get_tool_name(line,EOF_INIDICATOR);  
        disp(['Reading file: ' output_filepath]);
        while ~strcmp(line,EOF_INIDICATOR)
            tool_scores{end+1}.name = line_first;
            tool_scores{end}.ptool_scores = {};
            tool_scores{end}.ptool_median_scores = [];
            line_first = get_ptool_line(fgetl(fid_output));
            k = 0;
            while ~strcmp(line_first,'tool') && ~strcmp(line_first,EOF_INIDICATOR)
                k = k + 1;
                line_first = get_line_first_el(fgetl(fid_output));
                line_first = get_line_first_el(fgetl(fid_output));        
                scores = [];            
                while ~strcmp(line_first,'end_trial') && ~strcmp(line_first,EOF_INIDICATOR)                
                    tot_n_sim = tot_n_sim + 1;
                    score = str2double(line_first);
                    if score >= 0
                        scores(end+1) = score;                 
                    end
                    line_first = get_line_first_el(fgetl(fid_output));                       
                end    
                if isempty(scores)
                    scores = 0;
                end
                tool_scores{end}.ptool_scores{end+1} = scores;
                tool_scores{end}.ptool_median_scores(end+1) = floor(median(tool_scores{end}.ptool_scores{end}));
                all_tool_scores(end+1) = tool_scores{end}.ptool_median_scores(end);
                if tool_scores{end}.ptool_median_scores(end) <= 0
                    n_failed_sim = n_failed_sim + 1;
                    disp(['Simulation failed: tool: ' tool_scores{end}.name '    ptool: ' num2str(k)  ]);
                    failed_tool_ptool_ixs(end+1,1) = numel(tool_scores);
                    failed_tool_ptool_ixs(end,2) = numel(tool_scores{end}.ptool_median_scores);
                end
                [line_first, line] = get_line_first_el(fgetl(fid_output));
            end  
            [best_ptool_scores(end+1), best_ptools_ixs(end+1)] = max(tool_scores{end}.ptool_median_scores);
            line_first = get_tool_name(line,EOF_INIDICATOR);
        end
    end
    perc_failed_simulations = num2str(round(100*n_failed_sim/tot_n_sim));
    disp(['Failed simulations: ' num2str(n_failed_sim) '/' num2str(tot_n_sim) ' (' perc_failed_simulations ' %)']);
    disp('Merging calibration into one structure of list of tools');
    backup_filepath = [dataset_folder 'calib_res_' task backup_file_suffix '_' date '.mat'];
    disp(['Saving calibration results to: ' backup_filepath]);
    save(backup_filepath);    
    [tools, tool_scores, best_ptool_scores] = MergeCalibrationResultsPtoolData( dataset_folder, extracted_ptools_filename, backup_filepath );
    backup_filepath_=backup_filepath;
    load([dataset_folder extracted_ptools_filename]);
    backup_filepath=backup_filepath_;
    disp(['Re-Saving (after merging) calibration results to: ' backup_filepath]);
    save(backup_filepath);
end

% sorts up to 99 files
function sorted_filenames = SortFileNames(filenames)    
    file_nums = zeros(1,numel(filenames));
    for f=1:numel(filenames)
        file_num = str2double(filenames{f}(end-1:end));
        if isnan(file_num)
            file_num = str2double(filenames{f}(end));
        end
        file_nums(f) = file_num;
    end
    [~,b] = sort(file_nums);
    sorted_filenames = filenames(b);
end

function [line_first, line] = get_line_first_el(line)
    try
        line_split = strsplit(line);
        line_first = line_split{1};
    catch
        line_first = line;
    end
end

function ptool_line = get_ptool_line(line)
    line_split = strsplit(line);
    if strcmp(line_split{1},'ptool')
        ptool_line = line_split{1};
    else
        disp(line);
        error('Line does not contain a ptool indication (e.g. it should be ''ptool 7''');
    end
end

function task = get_task(line)
    line_split = strsplit(line);
    if strcmp(line_split{1},'task')
        task = line_split{2};
    else
        error('Line does not contain the task name (e.g. it should be ''task hammering_nail'')');
    end
end

function n_trials = get_n_trials(line)
    line_split = strsplit(line);
    if strcmp(line_split{1},'n_trials')
        n_trials = str2double(line_split{2});
    else
        disp(line);
        error('Line does not contain the number of trials (e.g. it should be ''n_trials 3'' for indicating 3 trials)');
    end
end

function tool_name = get_tool_name(line,EOF_INIDICATOR)
    line_split = strsplit(line);
    if strcmp(line_split{1},EOF_INIDICATOR)
       tool_name = EOF_INIDICATOR; 
       return;
    end
    if strcmp(line_split{1},'tool')
        line_split = strsplit(line_split{2},'/');
        tool_name = line_split{2};
    else
        disp(line);
        error('Line does not contain a tool name (e.g. it should be ''tool 3dwh_calibration/breadknife1'')');
    end
end

function [ tools, tool_scores, best_ptool_scores ] = MergeCalibrationResultsPtoolData( dataset_folder, extracted_ptools_filename, backup_filepath )
    %% load ptool data file
    load(backup_filepath);
    load([dataset_folder extracted_ptools_filename]);
    tools = cell(numel(pcl_filenames),1);
    tool_scores = reshape(tool_scores,numel(tool_scores),1);
    tot_toc = 0;
    %% get swap indexes
    swap_ixs = zeros(numel(pcl_filenames),1);
    for i=1:numel(pcl_filenames)
        pcl_shortname = GetPCLShortName(pcl_filenames{i});
        for j=1:numel(tool_scores)
            tool_shortname = tool_scores{j}.name;            
            if strcmp(tool_shortname,pcl_shortname)
                swap_ixs(i) = j;
                break;
            end
        end
    end      
    tool_scores_copy = tool_scores;
    best_ptool_scores_copy = best_ptool_scores;
    %% swap tools
    for i=1:numel(tool_scores)
        best_ptool_scores(i) = best_ptool_scores_copy(swap_ixs(i));
        tool_scores{i} = tool_scores_copy{swap_ixs(i)};
        tools{i}.name = tool_scores{i}.name;
        tools{i}.ptool_scores = tool_scores{i}.ptool_scores;
        tools{i}.ptool_median_scores = tool_scores{i}.ptool_median_scores;
        tools{i}.ptools = ptools{i};
        tools{i}.ptools_maps = ptools_maps{i};
        tools{i}.P = Ps{i};       
    end
%     for i=1:numel(tool_scores)
%         tools{i}.name = tool_scores{i}.name;
%         tools{i}.tool_scores = tool_scores{i};
%         tools{i}.ptools = ptools{i};
%         tools{i}.ptools_maps = ptools_maps{i};
%         tools{i}.P = Ps{i};        
%     end
    clear tool_scores_copy;
    clear tools_copy; 
    clear i;
    clear j;
    clear P;
    clear pcl_filenames;
    clear Ps;
    clear ptool_data_filename;
    clear ptools;
    clear ptools_maps;
    clear tool_name;
    disp('Saving data file...');
    save([root_folder task '_tools_ptools_calibration.mat']);
end

