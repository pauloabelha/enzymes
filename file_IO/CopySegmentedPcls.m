function [ output_args ] = CopySegmentedPcls( segm_folder, names_folder, dest_folder )
    segm_pcls_names = FindAllFilesOfType( {'ply'},segm_folder);
    % get names to copy
    names_cp = FindAllFilesOfType( {'ply'},names_folder);
    for i=1:size(names_cp,2)
        shortname_cp = names_cp{i}(1:findstr('ply',names_cp{i})-2);
        for j=1:size(segm_pcls_names,2)
            if findstr(shortname_cp,segm_pcls_names{j}) == 1
                command = ['cp ' segm_folder segm_pcls_names{j} ' ' dest_folder segm_pcls_names{j}];
                system(command);
                disp(['Copied point cloud ' num2str(i) '/' num2str(size(names_cp,2)) ' ' segm_pcls_names{j} ' into ' dest_folder]);
            end
        end       
    end
end

