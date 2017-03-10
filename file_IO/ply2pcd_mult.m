
%please define a root folder variable where the pcls are
root_folder = '~/Desktop/test/autosegmentation_core_4/';

folders = {''};

initial_pcl_ix = 1;
if exist('pcl_name_to_start','var') && ~strcmp(pcl_name_to_start,'')
    for i=1:size(pcl_filenames,2)
        if strcmp(pcl_name_to_start,pcl_filenames{i})
            initial_pcl_ix= i+1;
            break;
        end    
        disp([num2str(floor(i/size(pcl_filenames,2)*100)) ' %']);
    end
end

tot_toc = 0;
for f=1:size(folders,2)
    pcl_filenames = FindAllFilesOfType( {'ply'},[root_folder folders{f}]);
    for i=initial_pcl_ix:size(pcl_filenames,2)
        tic;
        if ~isempty(findstr('out',pcl_filenames{i}))
            try
                P = ReadPointCloud([root_folder folders{f} pcl_filenames{i}],0);
                if min(min(P.f)) > 0
                   P.f = P.f - 1;
                end    
                if ~isempty(P.segms)
                    P = AddColourToSegms(P); 
                end
                WritePcd(P,[root_folder folders{f} pcl_filenames{i}(1:end-3) 'pcd']);
                disp(['Pointcloud ' pcl_filenames{i} ' ' num2str(i) '/' num2str(size(pcl_filenames,2))]);
                tot_toc = tot_toc+toc;
                avg_toc = tot_toc/i;
                estimated_time_hours = (avg_toc*(size(pcl_filenames,2)-i))/(24*60*60);
                disp(['Estimated time to finish (HH:MM:SS): ' datestr(estimated_time_hours, 'HH:MM:SS')]);
            catch 
                warning(['Could not convert pointcloud ' pcl_filenames{i}]);
            end
        end    
    end
end