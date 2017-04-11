% extract a list of ptools from a given folder
function [ ptools, ptools_maps, Ps, pcl_filenames ] = ExtractPToolsFromFolder( root_folder )
    %% read groundtruth csv file (from hammering nail, but it just to get mass)
    [ tool_names, tool_masses ] = ReadGroundTruth([root_folder 'groundtruth_hammering_nail.csv']);
    CheckIsChar(root_folder);
    if ~exist('ext','var')
        exts = {'ply'};
    end
    pcl_filenames = FindAllFilesOfType(exts,root_folder);
    % check that every pcl in folder has a corresponding groundtruth
    for i=1:numel(pcl_filenames)
        pcl_shortname = GetPCLShortName(pcl_filenames{i});
        found_pcl_name = 0;
        for j=1:numel(tool_names)
            if strcmp(pcl_shortname,tool_names{j})
                found_pcl_name = 1;
                break;                
            end
        end
        if ~found_pcl_name
            error(['Could not find groundtruth for pcl ' pcl_filenames{i}]);
        end
    end 
    tot_toc = 0;
    Ps = {};
    ptools = {};
    ptools_maps = {};
    for i=1:size(pcl_filenames,2)
        tic;
        Ps{end+1} = ReadPointCloud([root_folder pcl_filenames{i}]);
        SQs = PCL2SQ( Ps{end}, 4, 0, 0, [1 1 1 0 1] );
        SQs_alt = GetRotationSQFits( SQs, Ps{end}.segms );
        [ ptools{end+1}, ptools_maps{end+1} ] = ExtractPToolsAltSQs(SQs_alt, tool_masses(i));
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(pcl_filenames,2),['Extracting ptools from folder: ' root_folder '/' pcl_filenames{i} ' ']);        
    end
    disp(['Saving extracted ptools to: ' root_folder 'extracted_ptools.mat' ]);
    save([root_folder 'ptools_training.mat']);
end

