function [file_suffix] = GetFileSuffixCurrentTime()
    file_suffix = datestr(datetime('now'), 'yyyymmddHHMMSS');
end

