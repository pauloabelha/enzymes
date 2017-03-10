function [ filenames_type ] = FindAllFilesOfType( list_types, folder_path, rmv_ext )
    %whether to remove extension form filename
    if ~exist('rmv_ext','var')
        rmv_ext = 0;
    end
    listing = dir(folder_path);
    all_filenames = {listing.name};
    filenames_type = {};
    ix_temp=1;
    for i=1:size(all_filenames,2)
        for j=1:size(list_types,2)
            if length(all_filenames{i}) > 5 && strcmp(all_filenames{i}(end-2:end),list_types(j))
                filenames_type{ix_temp} = all_filenames{i};
                if rmv_ext
                    filenames_type{ix_temp} = filenames_type{ix_temp}(1:end-4);
                end
                ix_temp=ix_temp+1;
                break;
            end
        end
    end
end

