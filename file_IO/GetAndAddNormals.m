function [ output_args ] = GetAndAddNormals( root_folder, normals_folder, pcls_wout_normals_folder )
    cd(strcat(root_folder,normals_folder));
    
    dirData = dir(pwd);      %# Get the data for the current directory
    dirIndex = [dirData.isdir];  %# Find the index for directories
    fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
    if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(pwd,x),...  %# Prepend path to files
                       fileList,'UniformOutput',false);
    end
    subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
    validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
                                               %#   that are not '.' or '..'
    for iDir = find(validIndex)                  %# Loop over valid subdirectories
        nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
        fileList = [fileList; getAllFiles(nextDir)];  %# Recursively call getAllFiles
    end

    normals = cell(size(fileList,1),2);
    for i=1:size(fileList,1)
      normals{i,1} = fileList{i};
      [P, ~] = ReadPointCloud(normals{i,1},100);
      normals{i,2} = P.n;
    end
    
    cd(strcat(root_folder,pcls_wout_normals_folder));   
    
    dirData = dir(pwd);      %# Get the data for the current directory
    dirIndex = [dirData.isdir];  %# Find the index for directories
    fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
    if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(pwd,x),...  %# Prepend path to files
                       fileList,'UniformOutput',false);
    end
    subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
    validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
                                               %#   that are not '.' or '..'
%     for iDir = find(validIndex)                  %# Loop over valid subdirectories
%         nextDir = fullfile(pwd,subDirs{iDir});    %# Get the subdirectory path
%         fileList = [fileList; getAllFiles(nextDir)];  %# Recursively call getAllFiles
%     end
    
    path_processed_folder = strcat([pwd,'\processed']);
    mkdir(path_processed_folder);
    for i=1:size(fileList,1)        
        [~,pcl_filename,~] = fileparts(fileList{i});
        disp(pcl_filename);
        file_found=0;
        for j=1:size(normals,1)
            if ~isempty(normals{j,1})
                [~,normal_filename,~] = fileparts(normals{j,1});
                if strfind(pcl_filename, normal_filename) == 1
                    [P, ~] = ReadPointCloud(fileList{i},100);  
                    P.n = normals{j,2};
                    WritePcd( P, strcat([path_processed_folder,'\',pcl_filename,'_processed.pcd']) );
                    normals{j,1} = [];
                    file_found=1;
                end
                if file_found
                    break;
                end
            end
        end
    end
end

