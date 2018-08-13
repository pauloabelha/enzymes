root_folder = '/home/paulo/skill_transfer/point_clouds/';
task = 'scooping';
points = '[0.15 0.15 0.15]';
pcl_downsampling = '500';
verbose = '1';
parallel = '0';

pcl_filenames = FindAllFilesOfType({'ply'}, root_folder);
for i=1:size(pcl_filenames,1)
    %disp(pcl_filenames{i});
    found_bowl = strfind(pcl_filenames{i}, 'bowl') > 0;
    if isempty(found_bowl)
        found_pot = strfind(pcl_filenames{i}, 'pot') > 0;
        if isempty(found_pot)
            found_mug = strfind(pcl_filenames{i}, 'mug') > 0;
            if isempty(found_mug)
                found_cup = strfind(pcl_filenames{i}, 'cup') > 0;
                if isempty(found_cup)
                    continue
                end
            end
        end
    end
    disp(pcl_filenames{i});
    P = ReadPointCloud([root_folder pcl_filenames{i}]);
    for angle=0:pi/3:pi
        P = Apply3DTransfPCL(P,GetRotMtx(angle, 'z'));
        GetTargetObjInfo( P, points, task, verbose, pcl_downsampling, parallel, ['_' num2str(angle)]);
    end
end