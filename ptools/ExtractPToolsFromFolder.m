% extract a list of ptools from a given folder
function [ ptools, ptools_maps, Ps, pcl_filenames ] = ExtractPToolsFromFolder( root_folder, suffix_bkp_file )
    if ~exist('suffix_bkp_file','var')
        suffix_bkp_file = '';
    end
    %% read groundtruth csv file (from hammering nail, but it just to get mass)
    [ tool_names, tool_masses ] = ReadGroundTruth([root_folder 'groundtruth_mass.csv']);
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
    Ps = cell(1,numel(pcl_filenames));
    ptools = cell(1,numel(pcl_filenames));
    ptools_maps = cell(1,numel(pcl_filenames));
    tot_n_ptools = 0;
    for i=1:numel(pcl_filenames)
        try
            tic;
            Ps{i} = ReadPointCloud([root_folder pcl_filenames{i}]);
            SQs = PCL2SQ( Ps{i}, 4, 0, 0, [1 1 1 0 1] );
            if numel(SQs) == 1
                [ ptools{i}, ptools_maps{i}(1:3), ptools_maps{i}(4:6) ] = ExtractPTool(SQs{1},SQs{1},tool_masses(i));
            else
                SQs_alt = GetRotationSQFits( SQs, Ps{i}.segms );
                [ ptools{i}, ptools_maps{i} ] = ExtractPToolsAltSQs(SQs_alt, tool_masses(i));
            end
            n_ptools = size(ptools{i},1);
            tot_n_ptools = tot_n_ptools + n_ptools;
            disp(['Extracted #' num2str(i) ' pcl ' pcl_filenames{i} ' (#ptools ' num2str(n_ptools) ') Tot # ' num2str(tot_n_ptools) ' Avg # ' num2str(floor(tot_n_ptools/i))]);
            backup_filepath = [root_folder 'extracted_ptools_' date suffix_bkp_file '.mat'];
            disp(['Saving extracted ptools to: ' backup_filepath]);
            save(backup_filepath);
            tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,numel(pcl_filenames));                
        catch E
            disp(['ERROR in pcl: ' pcl_filenames{i}]);
            warning(E.message);
        end
    end
    backup_filepath = [root_folder 'extracted_ptools_' date suffix_bkp_file '.mat'];
    disp(['Saving extracted ptools to: ' backup_filepath]);
    save(backup_filepath);
end

