% By Paulo Abelha
%
% Generates a parametrizable rectangular box for Gazebo
% I use it to generate the box that holds the grains for my
%   'scooping_grains' task
% This was very useful when I was extensively
%   experimenting with different boxes
%
% task_folder is the folder with the .world, tool(s) and task code
%   (e.g. '~/.gazebo/gazebo_models/scooping_grains/')
% box_name - the name to put in the sdf (be creative!)
%
% bottom_pose - 1x3 array with the x,y,z pose of the box centre
% width (as in gazebo's y axis)
% length (as in gazebo's x axis)
% height (I leave it as an exercise to guess this variable)
% thickness (thickness of each wall)
% description (last chance to be creative)
function GenerateBoxSDF( task_folder, box_name, bottom_pose, width, length, height, thickness, description )

    sdf_version = '1.6';
    author_name = 'Paulo Abelha';
    author_email = 'p.abelha@abdn.ac.uk';
    
    if ~exist('description','var')
        description = '';
    end
    
    system(['mkdir ' task_folder box_name]);    
    GenerateModelConfigFile([task_folder box_name], sdf_version, box_name, author_name, author_email, description);

    filepath = [task_folder box_name '/' box_name '.sdf'];
    fid = fopen(filepath,'w+');

    fprintf(fid,'<?xml version=''1.0''?>');
    fprintf(fid,'\n');
    fprintf(fid,['<sdf version=''' sdf_version '''>']);
    fprintf(fid,'\n');
    fprintf(fid,['\t<model name=''' box_name '''>']);
    fprintf(fid,'\n');
    fprintf(fid,['\t<pose>' num2str(bottom_pose(1)) ' ' num2str(bottom_pose(2)) ' ' num2str(bottom_pose(3)) ' 0 0 0 </pose>']);
    fprintf(fid,'\n');
    fprintf(fid,'\t<static>true</static>');
    fprintf(fid,'\n');
    fprintf(fid,'\n');
    
    pos_0 = [0 0 thickness/2];
    size_0 = [length, width, thickness];
    GenerateLinkTag(fid, [box_name '_' num2str(0)], pos_0, size_0, 2000, 2000, 'WoodFloor');
    fprintf(fid,'\n');
    fprintf(fid,'\n');    
    pos_1 = [(-length/2)+thickness/2, 0, thickness + (height/2)];  
    size_1 = [thickness, width - (2*thickness), height];
    GenerateLinkTag(fid, [box_name '_' num2str(1)], pos_1, size_1, 2000, 2000, 'WoodFloor');
    fprintf(fid,'\n');
    fprintf(fid,'\n');
    pos_2 = pos_1;
    pos_2(1) = -pos_1(1);
    size_2 = size_1;
    GenerateLinkTag(fid, [box_name '_' num2str(2)], pos_2, size_2, 2000, 2000, 'WoodFloor');
    fprintf(fid,'\n');
    fprintf(fid,'\n');
    pos_3 = [0, (-width/2)+thickness/2, thickness + (height/2)];  
    size_3 = [length, thickness, height];
    GenerateLinkTag(fid, [box_name '_' num2str(3)], pos_3, size_3, 2000, 2000, 'WoodFloor');
    fprintf(fid,'\n');
    fprintf(fid,'\n');
    pos_4 = pos_3;  
    pos_4(2) = -pos_3(2);
    size_4 = size_3;
    GenerateLinkTag(fid, [box_name '_' num2str(4)], pos_4, size_4, 2000, 2000, 'WoodFloor');
    fprintf(fid,'\n');
    fprintf(fid,'\n');
    
    fprintf(fid,'\t</model>');
    fprintf(fid,'\n');
    fprintf(fid,'</sdf>');

    fclose(fid);
end

function GenerateGeometryTag(fid, size)
    fprintf(fid,'\t\t<geometry>');
    fprintf(fid,'\n');
    fprintf(fid,'\t\t\t<box>');
    fprintf(fid,'\n');
    fprintf(fid,['\t\t\t\t<size>' num2str(size(1)) ' ' num2str(size(2)) ' ' num2str(size(3)) '</size>']);
    fprintf(fid,'\n');
    fprintf(fid,'\t\t\t</box>');
    fprintf(fid,'\n');
    fprintf(fid,'\t\t</geometry>');
end

function GenerateSurfaceTag(fid, mu, mu2)
    fprintf(fid,'\t\t<surface>');
    fprintf(fid,'\n');
    fprintf(fid,'\t\t\t<friction>');
    fprintf(fid,'\n');
    fprintf(fid,'\t\t\t\t<ode>');
    fprintf(fid,'\n');
    fprintf(fid,['\t\t\t\t\t<mu>' num2str(mu) '</mu>']);
    fprintf(fid,'\n');
    fprintf(fid,['\t\t\t\t\t<mu2>' num2str(mu2) '</mu2>']);
    fprintf(fid,'\n');
    fprintf(fid,'\t\t\t\t</ode>');
    fprintf(fid,'\n');
    fprintf(fid,'\t\t\t</friction>');
    fprintf(fid,'\n');
    fprintf(fid,'\t\t</surface>');
end

function GenerateMaterialTag(fid, material)
    fprintf(fid,'\t\t<material>');
    fprintf(fid,'\n');
    fprintf(fid,'\t\t\t<script>');
    fprintf(fid,'\n');
    fprintf(fid,'\t\t\t\t<uri>file://media/materials/scripts/gazebo.material</uri>');
    fprintf(fid,'\n');
    fprintf(fid,['\t\t\t\t<name>Gazebo/' material '</name>']);
    fprintf(fid,'\n');
    fprintf(fid,'\t\t\t</script>');
    fprintf(fid,'\n');
    fprintf(fid,'\t\t</material>');
end


function GenerateLinkTag(fid, name, pose, size, mu1, mu2, material)
    fprintf(fid,['\t<link name=''' name '''>']);
    fprintf(fid,'\n');
    fprintf(fid,['\t\t<pose>' num2str(pose(1)) ' ' num2str(pose(2)) ' ' num2str(pose(3)) ' 0 0 0 </pose>']);
    fprintf(fid,'\n');
    coliision_name = [name  '_coliision'];
    fprintf(fid,['\t\t<collision name=''' coliision_name '''>']);
    fprintf(fid,'\n');
    GenerateGeometryTag(fid, size);
    fprintf(fid,'\n');
    GenerateSurfaceTag(fid, mu1, mu2);
    fprintf(fid,'\n');
    fprintf(fid,'\t\t</collision>');
    fprintf(fid,'\n');
    fprintf(fid,'\n');
    visual_name = [name  '_visual'];
    fprintf(fid,['\t\t<visual name=''' visual_name '''>']);
    fprintf(fid,'\n');
    GenerateGeometryTag(fid, size);
    fprintf(fid,'\n');
    GenerateMaterialTag(fid, material);
    fprintf(fid,'\n');
    fprintf(fid,'\t\t</visual>');   
    
    fprintf(fid,'\t</link>');
end

function GenerateModelConfigFile(root_folder, sdf_version, name, author_name, author_email, description)
    filepath = [root_folder '/model.config'];
    fid = fopen(filepath,'w+');

    fprintf(fid,'<?xml version=''1.0''?>');
    fprintf(fid,'\n');
    fprintf(fid,['\t<model>']);
    fprintf(fid,'\n');
    fprintf(fid,['\t\t<name>' name '</name>']);
    fprintf(fid,'\n');
    fprintf(fid,['\t\t<sdf version=''' sdf_version '''>' name '.sdf</sdf>']);
    fprintf(fid,'\n');    
    fprintf(fid,['\t\t<author>']);
    fprintf(fid,'\n');    
    fprintf(fid,['\t\t\t<name>' author_name '</name>']);
    fprintf(fid,'\n');    
    fprintf(fid,['\t\t\t<email>' author_email '</email>']);
    fprintf(fid,'\n');    
    fprintf(fid,['\t\t</author>']);
    fprintf(fid,'\n');
    fprintf(fid,['\t\t<description>']);
    fprintf(fid,'\n');
    fprintf(fid,['\t\t\t' description]);
    fprintf(fid,'\n');
    fprintf(fid,['\t\t</description>']);
    fprintf(fid,'\n'); 
    fprintf(fid,['\t</model>']);
end

