function [ new_output_scores ] = GetScoreForEveryTool( root_folder, pcl_filenames, output_scores )
    groundtruth = readtable([root_folder 'groundtruth.csv']);
    new_output_scores = zeros(size(groundtruth.tool,1),1); 
    new_output_scores(:) = NaN;
    for i=1:size(groundtruth.tool,1)
        pcl_gt_shortname = GetPCLShortName(groundtruth.tool{i});
        found_pcl=0;
        disp('---------------------------------------------------------------');
        for j=1:size(pcl_filenames,2)
            disp(pcl_filenames{j});
            if strcmp(pcl_filenames{j},pcl_gt_shortname)
                new_output_scores(i) = output_scores(j);
                found_pcl = 1;
            end
        end
        if ~found_pcl
            warning(['Could not find pcl ' pcl_gt_shortname]);
        end
    end    
end

