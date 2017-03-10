function Ps = ReadMyersPcls( root_folder, tool_name )
    [ folders ] = FindAllFolders( [root_folder 'tools/'] );
    for f=1:size(folders,2)
        if strcmp(tool_name,folders{f}(1:end-1))
           break;
        end
    end
    [ filenames_type ] = FindAllFilesOfPrefix( '', [root_folder 'tools/' folders{f}] );
    n_shots = size(filenames_type,2)/4; 
    tot_toc = 0;
    Ps = cell(1,n_shots);
    for i=1:n_shots
        tic;
        tool_prefix = folders{f}(1:end-1);
        tool_numbering = get_tool_numbering_myers2015(i);
        tool_name = [tool_prefix '_' tool_numbering];
        tool_image_filename = [tool_name '_depth.png'];
        [P, P_raw] = read_png_as_pcl_myers2015( [root_folder 'tools/' folders{f} tool_image_filename] );
%         P = read_png_as_pclwithtable_myers2015( P_raw );        
        if i == 1
            mean_desl = mean(P.v);
        end
        P.v = P.v - mean_desl;
        rot_y = GetRotMtx(-pi/3.5,'y');
        P = Apply3DTransfPCL({P},{rot_y});
        P.segms{1}.v = P.segms{1}.v/1000;
        P.segms{1}.v = P.segms{1}.v - mean_desl;
        Ps{i} = P;
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,n_shots);
    end
end

