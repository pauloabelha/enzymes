% extract a list of ptools from a given folder
function [ ptools, ptools_maps, Ps, pcl_filenames ] = ExtractPToolsFromFolder( root_folder, task )
    %% read groundtruth csv file
    GT = ReadCSVGeneric([root_folder 'groundtruth_' task '.csv']);
    masses = GT(:,3);
    CheckIsChar(root_folder);
    if ~exist('ext','var')
        exts = {'ply'};
    end
    pcl_filenames = FindAllFilesOfType(exts,root_folder);
    % check if groundtruth correponds to pcl filenames
    for i=1:numel(pcl_filenames)
        if ~strcmp(GetPCLShortName(pcl_filenames{i}),GT{i,2})
            error([num2str(i) 'GT does not correspond to pcl filenames']);
        end
    end 
    tot_toc = 0;
    Ps = {};
    ptools = {};
    ptools_maps = {};
    for i=1:size(pcl_filenames,2)
        tic;
        Ps{end+1} = ReadPointCloud([root_folder pcl_filenames{i}]);
        SQs = PCL2SQ( Ps{end}, 1, 0, 0, [1 1 1 0 1] );
        SQs_alt = GetRotationSQFits( SQs, Ps{end}.segms );
        [ ptools{end+1}, ptools_maps{end+1} ] = ExtractPToolsAltSQs(SQs_alt, str2double(masses{i}));
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(pcl_filenames,2),['Extracting ptools from folder: ' root_folder '/' pcl_filenames{i} ' ']);        
    end
    disp(['Saving extracted ptools to: ' root_folder 'extracted_ptools.mat' ]);
    save([root_folder 'ptools_training.mat']);
end

