function [ output_args ] = ConvertMyers2015RGBDToPly( root_folder, slash )    
    if ~exist('slash','var')
        slash = '/';
    end
    system(['mkdir ' root_folder 'converted']);
    [ folders ] = FindAllFolders( [root_folder 'tools' slash], slash );
    tot_toc = 0;    
    parfor f=1:size(folders,2)
        tic;
        system(['mkdir ' root_folder 'converted' slash folders{f}]);
        system(['mkdir ' root_folder 'converted' slash folders{f} 'segmented' slash]);
        system(['mkdir ' root_folder 'converted' slash folders{f} 'with_table' slash]);
        [ filenames_type ] = FindAllFilesOfPrefix( '', [root_folder 'tools' slash folders{f}] );
        n_shots = size(filenames_type,2)/4;
        for i=1:n_shots
            tool_prefix = folders{f}(1:end-1);
            tool_numbering = get_tool_numbering_myers2015(i);
            tool_name = [tool_prefix '_' tool_numbering];
            tool_image_filename = [tool_name '_depth.png'];
            [P, P_raw] = read_png_as_pcl_myers2015( [root_folder 'tools' slash folders{f} tool_image_filename], slash );
            WritePly(P,[root_folder 'converted' slash folders{f} 'segmented' slash tool_name '_segmented.ply']);
            P = read_png_as_pclwithtable_myers2015( P_raw );
            WritePly(P,[root_folder 'converted' slash folders{f} 'with_table' slash tool_name '_with_table.ply']);
            disp(['Converting all pcls for tool ' tool_prefix ': ' num2str(round((i*100)/n_shots)) '%']);
        end
%         tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,f,size(folders,2));
    end


end