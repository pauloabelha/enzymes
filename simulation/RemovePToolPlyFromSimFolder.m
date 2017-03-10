function [ output_args ] = RemovePToolPlyFromSimFolder( root_folder )
    
    folders = FindAllFolders(root_folder);
    tot_toc = 0;
    for i=1:size(folders,2)
        tic;
        command = ['rm ' root_folder folders{i} 'pTool.ply'];
        system(command);
        disp(command);
        perc_completed = ceil((i/size(pcl_filenames,2))*100);
        tot_toc = tot_toc+toc;
        avg_toc = tot_toc/i;
        estimated_time_hours = (avg_toc*(size(folders,2)-i))/(24*60*60);
        disp(['Estimated time to finish (HH:MM:SS): ' datestr(estimated_time_hours, 'HH:MM:SS') '    ' num2str(perc_completed) ' %']);
    end


end

