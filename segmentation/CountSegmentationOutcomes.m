function [ n_segmentations, pcl_names_set ] = CountSegmentationOutcomes( root_folder, extension, folders  )    

    if ~exist('extension','var')
        extension = 'ply';
    end

    if ~exist('folders','var')
        folders = {''};
    end
    
    pcl_names_set = {};
    n_segmentations = [];
    for f=1:size(folders,2)
        pcl_filenames = FindAllFilesOfType( {extension}, [root_folder folders{f}] );        
        for i=1:size(pcl_filenames,2)
            pcl_shortname = GetPCLShortName(pcl_filenames{i});
            if ~ismember(pcl_shortname,pcl_names_set)
                pcl_names_set{end+1} = pcl_shortname;
                n_segmentations(end+1) = 1;
                for j=i+1:size(pcl_filenames,2)
                    pcl_shortname_comp = GetPCLShortName(pcl_filenames{j});
                    if strcmp(pcl_shortname,pcl_shortname_comp)
                        n_segmentations(end) = n_segmentations(end) + 1;
                    end
                end
            end
        end
    end

    plot(n_segmentations);
    ax = gca;
    ax.XTickLabel = pcl_names_set;
    ax.XTickLabelRotation = 90;
    ax.XTick = 1:size(pcl_names_set,2); 
end

