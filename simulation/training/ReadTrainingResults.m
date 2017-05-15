function [ ptool_median_scores, ptool_scores, task, failed_ptool_ixs ] = ReadTrainingResults( output_filepath, n_files )
    %% end of file indicator
    EOF_INIDICATOR = 'end_calibration';
    %% Open file
    if ~exist('n_files','var')
        output_filepathes = {output_filepath};
    else
        output_filepathes = {};
        for i=1:n_files
            output_filepathes{end+1} = [output_filepath(1:end-5) num2str(i) '.txt'];
        end    
    end
    ptool_scores = [];
    ptool_median_scores = [];
    for file_ix=1:numel(output_filepathes)
        output_filepath = output_filepathes{file_ix};
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
        n_failed_sim = 0;
        tot_n_sim = 0;
        failed_ptool_ixs = [];
        i = 0;
        while ~feof(fid_output)
            i = i + 1;  
            line = fgetl(fid_output); 
            scores = [];
            while ~strcmp(line,'end_trial') && ~strcmp(line,EOF_INIDICATOR)                
                tot_n_sim = tot_n_sim + 1;
                score = str2double(line);
                if score >= 0
                    scores(end+1) = score;                 
                end
                line = get_line_first_el(fgetl(fid_output));
            end    
            if isempty(scores)
                scores = 0;
            end
            ptool_scores{end+1} = scores;
            ptool_median_scores(end+1) = median(ptool_scores{end});
            if ptool_median_scores(end) < 0
                n_failed_sim = n_failed_sim + 1;
                disp(['Simulation failed on tool: ' num2str(i)]);
                failed_ptool_ixs(end+1) = i;
            end
        end
        fclose(fid_output);
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

