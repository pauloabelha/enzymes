function [ folders ] = FindAllFolders( root_folder, slash )
    if ~exist('slash','var')
        slash = '/';
    end
    listing = dir(root_folder);
    all_folder_names = {listing.name};
    is_dirs = {listing.isdir};
    folders = {};
    for i=3:size(all_folder_names,2)
        if is_dirs{i}
            folders{end+1} = [all_folder_names{i} slash]; 
        end        
    end
end

