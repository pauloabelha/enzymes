function [ tool_scores, task, failed_tool_ptool_ixs, all_tool_scores, best_ptool_scores, best_ptools_ixs ] = ReadCalibrationResults( output_filepath )
    %% end of file indicator
    EOF_INIDICATOR = 'end_calibration';
    %% Open file
    fid_output = fopen(output_filepath);
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
    tool_scores = {};
    n_failed_sim = 0;
    tot_n_sim = 0;
    failed_tool_ptool_ixs = [];
    all_tool_scores = [];
    best_ptools_ixs = [];
    best_ptool_scores = [];
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
            tool_scores{end}.ptool_median_scores(end+1) = median(tool_scores{end}.ptool_scores{end});
            all_tool_scores(end+1) = tool_scores{end}.ptool_median_scores(end);
            if tool_scores{end}.ptool_median_scores(end) < 0
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
    perc_failed_simulations = num2str(round(100*n_failed_sim/tot_n_sim));
    disp(['Failed simulations: ' num2str(n_failed_sim) '/' num2str(tot_n_sim) ' (' perc_failed_simulations ' %)']);
end

function [line_first, line] = get_line_first_el(line)
    line_split = strsplit(line);
    line_first = line_split{1};
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

