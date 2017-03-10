function [ filenames_type ] = FindAllFilesOfPrefix( prefix, folder_path )
    listing = dir(folder_path);
    all_filenames = {listing.name};
    filenames_type = {};
    for i=3:size(all_filenames,2)
        if strcmp(prefix,'') || strcmp(prefix,'*') || (length(all_filenames{i}) >= length(prefix) && strcmp(prefix,all_filenames{i}(1:length(prefix))))
            filenames_type{end+1} = all_filenames{i};
        end
    end
end


