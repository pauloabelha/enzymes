function [ pcl_newfilenames ] = RenamePCLsInFolder( root_folder, exts )
    if ~exist('exts','var')
        exts = {'ply'};
    end
    pcl_filenames = FindAllFilesOfType(exts, root_folder);
    pcl_newfilenames = cell(1,numel(pcl_filenames));
    for i=1:numel(pcl_filenames)
        split_str = strsplit(pcl_filenames{i}, '3dwh');
        pcl_shortname = GetPCLShortName(pcl_filenames{i});
        pcl_shortname = FixShortName(pcl_shortname);
        pcl_shortname = [pcl_shortname '_3dwh.ply'];
        cmd = ['mv ' root_folder pcl_filenames{i} ' ' root_folder pcl_shortname];
        disp(cmd);
        system(cmd);
    end  
    
end

function new_name = FixShortName(pcl_shortname)
    split_name = strsplit(pcl_shortname,'_');
    if numel(split_name) == 1
        new_name = SeparateNumInName(split_name{1},pcl_shortname);
    else
        if ~isnan(str2double(split_name{2}))
            new_name = pcl_shortname;
        else
            new_name = SeparateNumInName(split_name{1}, pcl_shortname); 
        end
    end
end

function new_name = SeparateNumInName(name, full_name)
    num_str = '';
    found_num = 0;
    new_name = name;
    for i=1:numel(name)
       char_ =name(i);           
       if ~isnan(str2double(char_))
           found_num = 1;
           num_str = [num_str char_];
       end
    end
    if found_num
       name_split = strsplit(full_name, num_str(1));
       name1 = name_split{1};
       new_name = [name1 '_' num_str];
    end
end

