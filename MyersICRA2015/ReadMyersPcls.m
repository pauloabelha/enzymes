function [Ps, mins_xyz, maxs_xyz, est_rot_centre] = ReadMyersPcls( root_folder, tool_name )
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
    mins_xyz = [Inf Inf Inf];
    maxs_xyz = [-Inf -Inf -Inf];
    folder = folders{f};
    tool_prefix = folder(1:end-1);
    parfor i=1:n_shots
        tic;        
        tool_numbering = get_tool_numbering_myers2015(i);
        tool_name = [tool_prefix '_' tool_numbering];
        tool_image_filename = [tool_name '_depth.png'];
        [P, ~] = read_png_as_pcl_myers2015( [root_folder 'tools/' folder tool_image_filename] );
%         P = read_png_as_pclwithtable_myers2015( P_raw );        
        if i == 1
            mean_desl = mean(P.v);
        end
%         P.v = P.v - repmat(mean_desl,size(P.v,1),1);
        rot_y = GetRotMtx(-pi/3.5,'y');
        P = Apply3DTransfPCL({P},{rot_y});
        rot_y = GetRotMtx(pi,'y');
        P = Apply3DTransfPCL({P},{rot_y});
        P.segms{1}.v = P.segms{1}.v/1000;
        
        mins_xyz = min(mins_xyz,min(P.v,[],1));
        maxs_xyz = max(maxs_xyz,max(P.v,[],1));
        
%         P.segms{1}.v = P.segms{1}.v - repmat(mean_desl,size(P.segms{1}.v,1),1);
        Ps{i} = P;
%         tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,n_shots);
    end
    est_rot_centre = (mins_xyz+maxs_xyz)/2;
    parfor i=1:n_shots
        Ps{i}.v = Ps{i}.v - repmat(est_rot_centre,size(Ps{i}.v,1),1);
        Ps{i}.segms{1}.v = Ps{i}.segms{1}.v - repmat(est_rot_centre,size(Ps{i}.v,1),1);
    end
end

