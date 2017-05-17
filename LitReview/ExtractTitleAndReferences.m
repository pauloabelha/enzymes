function [ ref_titles, ref_strs ] = ExtractTitleAndReferences( root_folder, filename )
    MIN_TITLE_LENGTH = 20;
    MAX_TITLE_LENGTH = 200;
    %% convert file
    if strcmp(filename(end-2:end),'pdf')
        working_file = 'working_paper.';
        system(['pdftotext ' root_folder filename ' ' root_folder working_file 'txt']);
        filepath = [root_folder working_file 'txt'];
    end
    %% get references
    fid = fopen(filepath);
    if fid == -1
        system(['rm ' filepath(1:end-3) 'txt']);
        error(['Could not open file ' filepath ' - are you mising the extension in the filename?']);
    end
    str = '';
    lines_b4_abstract = {};
    found_abstract = 0;
    while ~feof(fid)
        line = fgetl(fid);      
        close_bracket = findstr(']', line);
        if~isempty(close_bracket)
            break;
        end
        if ~found_abstract
            if ~isempty(findstr('Abstract', line))
                found_abstract = 1;
            else
                lines_b4_abstract{end+1} = line;
            end
        end
    end
    last_empty_line_ix = 1;
%     for i=1:numel(lines_b4_abstract)-1
%         if strcmp(lines_b4_abstract{i},'')
%             last_empty_line_ix=i;
%         end
%     end
%     lines_b4_abstract = lines_b4_abstract(last_empty_line_ix+1:end-1);
%     paper_title = '';
%     for i=1:numel(lines_b4_abstract)
%         paper_title = [paper_title lines_b4_abstract{i}];
%     end
%     paper_title = lower(paper_title);
%     paper_title = replace(paper_title,' ','');
    str = [str line(close_bracket+1:end)];
    ref_strs = {};
    last_one_ix = 0;
    ix = 0;
    last_reference_line_ix = 0;
    lines_after_references = {};
    while ~feof(fid)  
        ix = ix + 1;
        line = fgetl(fid);
        if ~isempty(findstr('reference', replace(lower(line),' ','')))
            last_reference_line_ix = ix;
            lines_after_references = {};
        end 
        lines_after_references{end+1} = line;        
    end   
    ix = 0;
    for i=2:numel(lines_after_references)
        ix = ix + 1;
        line = lines_after_references{i};
        if last_reference_line_ix > 0
            close_bracket = findstr(']', line);
            open_bracket = findstr('[', line);
            ix_start = 1;
            if ~isempty(close_bracket)
                ix_start = close_bracket+1;
            end
            if ~isempty(open_bracket)
                str = [str line(1:open_bracket-1)];
                ref_strs{end+1} = str;
                str = line(open_bracket+3:end);
            else
                str = [str line];
            end
            if ~isempty(findstr('[1]', line))
                last_one_ix = ix;
                % reset reference strings (because not after last [1])
                ref_strs = {};
            end 
        end        
    end
    ref_strs{end+1}  =str;
    ref_titles = {};
    for i=1:numel(ref_strs)
        bracket_split = strsplit(ref_strs{i},'“');
        if numel(bracket_split) > 1
            bracket_split2 = strsplit(bracket_split{2},'”');
            if numel(bracket_split2{1}(1:end-1)) >= MIN_TITLE_LENGTH && numel(bracket_split2{1}(1:end-1)) <= MAX_TITLE_LENGTH
                ref_titles{end+1} = bracket_split2{1}(1:end-1);
            end
        else
            bracket_split = strsplit(ref_strs{i},' In');
            if numel(bracket_split) > 1
                bracket_split2 = strsplit(bracket_split{1},'.');
                if numel(bracket_split2{end-1}) >= MIN_TITLE_LENGTH && numel(bracket_split2{end-1}) <= MAX_TITLE_LENGTH
                    ref_titles{end+1} = bracket_split2{end-1}(2:end);
                end
            end
        end
        %disp(ref_strs{i});
    end
%     ref_titles = lower(ref_titles);
    for i=1:numel(ref_titles)
%         ref_titles{i} = replace(ref_titles{i},' ','');
%         disp(ref_titles{i});
    end
    system(['rm ' filepath(1:end-3) 'txt']);
end

