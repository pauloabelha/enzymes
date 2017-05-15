function [ Ps, all_ptools, all_ptools_struct, transfs_lists, pcl_filenames, ptool_ix_to_pcl_ix, pTools_SQs ] = GetPtoolsOnePclInFolder( pcl_in_shortname, root_folder_path, task_name, tool_mass, pcl_extension, pTool_prefix )
    % get the filename for every */pcd file in root_folder
    pcl_filenames = FindAllFilesOfType( {pcl_extension}, root_folder_path );
    temp = {};    
    for i=1:size(pcl_filenames,2)
        pcl_shortname = GetPCLShortName( pcl_filenames{i} );
        if ~isempty(pcl_shortname) && strcmp(pcl_in_shortname,pcl_shortname) 
            temp{end+1} = pcl_filenames{i};
        end
    end    
    pcl_filenames = temp;
    if isempty(pcl_filenames)
        error(['Could not find segmentation outcomes for ' pcl_in_shortname ' in ' root_folder_path]);
    end
    all_ptools = [];
    tot_toc = 0;    
    all_ptools_struct = {};
    transfs_lists = {};
    ptool_ix_to_pcl_ix = [];
    pTools_SQs = {};
    Ps = {};
    valid_ix=0;
    for i=1:size(pcl_filenames,2)
        tic           
        try                   
            [pTools_struct, pTools, transf_lists, P, SQs] = getPToolsFromPcl(root_folder_path,pcl_filenames{i},tool_mass,task_name,1.5,pTool_prefix);
            valid_ix=valid_ix+1;
            all_ptools = [all_ptools; pTools];
            for j=1:size(pTools,1)
               ptool_ix_to_pcl_ix = [ptool_ix_to_pcl_ix; valid_ix]; 
               all_ptools_struct{end+1} = pTools_struct{j};
               transfs_lists{end+1} = transf_lists{j};
            end
            pTools_SQs{end+1} = SQs;
            Ps{end+1} = P; 
            dlmwrite([root_folder_path 'pTools.txt'], pTools, 'delimiter', '\t','-append');
            disp(['Extracted pTool for ' pcl_filenames{i} ' ' num2str(tool_mass) ' ' num2str((i/size(pcl_filenames,2)*100)) '% ' num2str(i) '/' num2str(size(pcl_filenames,2)) ' pointclouds']);
        catch E           
            warning(['Could not extract pTools from ' pcl_filenames{i}]);
            warning(['Matlab error was: ' E.message]);
        end
        tot_toc = tot_toc+toc;
        avg_toc = tot_toc/i;
        estimated_time_hours = (avg_toc*(size(pcl_filenames,2)-i))/(24*60*60);
        disp(['Estimated time to finish (HH:MM:SS): ' datestr(estimated_time_hours, 'HH:MM:SS')]);            
    end
end



