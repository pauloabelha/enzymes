%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
%
%% This function will create a split of training, validation and test sets
% based on a folder with point clouds and a CSV groundtruth file
% Inputs:
%   root_folder - root folder with the point clouds and ground truth file
%   split_prop - a 3 * 1 array with the split proportion in training,
%       validation and test respectively
% Outputs:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ pcl_filenames ] = CreateTrainValidTestSet( root_folder, split_prop )
    %% sanity check on inputs
    if ~ischar(root_folder)
        error('Input root folder must be a string');
    end
    eps_prop = 1e-3;
    if size(split_prop,1) ~= 3
       error('Input split proportion must be a 3 * 1 array');  
    end
    if abs(sum(split_prop)-1) > eps_prop
       error('Input split proportion must sum to 1'); 
    end
    %% define folder names
    folders = {'training/' 'validation/' 'test/'};
    %% delete existing folders
    for i=1:3
        system(['rm -r ' root_folder folders{i}]);
    end
    %% read pcls and groundtruth from root folder
    pcl_filenames = FindAllFilesOfType( {'ply', 'pcd'},root_folder);
    table_gt = readtable([root_folder 'groundtruth.csv']); 
    %% partition the dataset into training, validation and testing
    n_pcls = size(table_gt.tool,1);
    ixs = randperm(n_pcls);
    % get training set indexes
    ixs_train(ixs(1:round(size(ixs,2)*split_prop(1)))) = 1;    
    ixs_train = logical(ixs_train);
    % get validation set indexes
    n_valid_test = size(ixs_train(ixs_train==0),2);
    n_valid_pcls = round(size(ixs,2)*split_prop(2));
    ixs_valid = [ones(n_valid_pcls,1)' zeros(n_valid_test-n_valid_pcls,1)'];
    ixs_test = ~ixs_valid;
    ixs_temp = zeros(size(ixs));
    ixs_temp(ixs_train==0) = ixs_valid;    
    ixs_valid = logical(ixs_temp);
    % get test set indexestraining
    ixs_temp = zeros(size(ixs));
    ixs_temp(ixs_train==0 & ixs_valid==0) = 1; 
    ixs_test = logical(ixs_temp);
    %% create folders
    for i=1:3
        system(['mkdir ' root_folder folders{i}]);
        fileattrib([root_folder folders{i}],'+w','a'); 
    end
    %% copy pcls into fodlers
    tot_toc = 0;
    for i=1:n_pcls
        tic
        % check if pcl exists in the folder
        pcl_present_in_folder=0;
        for j=1:size(pcl_filenames,2)
            if strcmp(table_gt.tool{i},pcl_filenames{j}) || strcmp(table_gt.tool{i},pcl_filenames{j}(1:end-4))
               pcl_present_in_folder=1; 
               break;
            end
        end
        if ~pcl_present_in_folder
            warning(['Could not find point cloud ' table_gt.tool{i} ' in root folder ' root_folder]);
            continue;
        end
        % copy pcl
        folder = 0;
        if ixs_train(i) == 1
            command = ['cp ' root_folder pcl_filenames{i} ' ' root_folder folders{1}];
            folder = 1;
        end
        if ixs_valid(i) == 1
            command = ['cp ' root_folder pcl_filenames{i} ' ' root_folder folders{2}];
            folder = 2;
        end
        if ixs_test(i) == 1
            command = ['cp ' root_folder pcl_filenames{i} ' ' root_folder folders{3}];
            folder = 3;
        end    
        if folder == 0
            error('Something went wrong in the splitting :(');
        end
        system(command);
        fileattrib([root_folder folders{folder} pcl_filenames{i}],'+w','a'); 
        disp(['Copied point cloud ' pcl_filenames{i} ' into folder ' folders{folder}]);
        tot_toc = tot_toc+toc;
        avg_toc = tot_toc/i;
        estimated_time_hours = (avg_toc*(size(pcl_filenames,2)-i))/(24*60*60);
        disp(['Estimated time to finish (HH:MM:SS): ' datestr(estimated_time_hours, 'HH:MM:SS')]);
    end
end