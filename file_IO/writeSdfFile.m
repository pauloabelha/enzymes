function [] = writeSdfFile( path, task, elbow_pos, tool_pos, tool_rot, action_tracker_pos, center_mass,mass,inertia, write_intertia)

    [model_name, task_pose_offset, sensor_plugin_filename, sensor_plugin_name, elbow_type, elbow_axis, action_tracker_type, action_tracker_axis, plugin_filename, plugin_name ] = getSdfFileParams(task);

	fid=fopen(strcat(path,'tool.sdf'),'w+');
    fprintf(fid,['<?xml version=''1.0''?>\n<sdf version=''1.6''>\n<model name="' model_name '">\n']);
    fprintf(fid,'<static>false</static>\n');
    fprintf(fid,['<pose> ' task_pose_offset ' 0 0 0 </pose>\n\n']);
    %% write link
    write_link(fid, elbow_pos + tool_pos, tool_rot, center_mass, mass,...
        write_intertia, inertia, task, sensor_plugin_filename,...
        sensor_plugin_name);
    %% write elbow
    if strcmp(elbow_type,'prismatic') || strcmp(elbow_type,'revolute')
       write_elbow(fid, elbow_type, elbow_pos, elbow_axis); 
    end
    %% write action tracker (if needed)
    write_action_tracker_model(fid, action_tracker_type, action_tracker_pos, action_tracker_axis);    
    %% close XML and close file
    fprintf(fid,['<plugin filename="' plugin_filename '" name="' plugin_name '"/>\n\n']);
    fprintf(fid,'</model>\n');
    fprintf(fid,'</sdf>\n');
    fclose(fid);
end

function write_action_tracker_model(fid, action_type, action_tracker_pos, joint_axis)
    if ~isempty(action_type)
        %% write model
        fprintf(fid,['<model name="' action_type '_model">\n']);
        fprintf(fid,'\t<pose>0 0 0 0 0 0</pose>\n');
        %% write link
        fprintf(fid,['\t<link name="' action_type '_link">\n']);
        fprintf(fid,'\t\t<pose>%.4f %.4f %.4f 0 0 0</pose>\n', action_tracker_pos(1), action_tracker_pos(2), action_tracker_pos(3));
        fprintf(fid,['\t\t<visual name="' action_type '_visual">\n']);
        %% write geometry
        fprintf(fid,'\t\t\t<geometry>\n');
        fprintf(fid,'\t\t\t\t<sphere>\n');
        fprintf(fid,'\t\t\t\t\t<radius>0.005</radius>\n');
        fprintf(fid,'\t\t\t\t</sphere>\n');
        fprintf(fid,'\t\t\t</geometry>\n');
        %% write material
        fprintf(fid,'\t\t\t<material>\n');
        fprintf(fid,'\t\t\t\t<script>\n');
        fprintf(fid,'\t\t\t\t\t<uri>file://media/materials/scripts/gazebo.material</uri>\n');
        fprintf(fid,'\t\t\t\t\t<name>Gazebo/Green</name>\n');
        fprintf(fid,'\t\t\t\t</script>\n');
        fprintf(fid,'\t\t\t</material>\n');
        %% close XML
        fprintf(fid,'\t\t</visual>\n');
        fprintf(fid,'\t</link>\n');
        fprintf(fid,'</model>\n\n');
        %% write joint
        fprintf(fid,['<joint name="joint_' action_type '" type="revolute">\n']);
        fprintf(fid,'\t<parent>tool</parent>\n');
        fprintf(fid,['\t<child>' action_type '_link</child>\n']);
        fprintf(fid,'\t<axis>\n');
        fprintf(fid,['\t\t<xyz>' joint_axis '</xyz>\n']);
        fprintf(fid,'\t\t<use_parent_model_frame>1</use_parent_model_frame>\n');
        fprintf(fid,'\t\t<dynamics>\n');
        fprintf(fid,'\t\t\t<friction>0.1</friction>\n');
        fprintf(fid,'\t\t</dynamics>\n');
        fprintf(fid,'\t</axis>\n');
        fprintf(fid,'</joint>\n\n');
    end
end

function write_elbow(fid, elbow_type, elbow_pos, elbow_axis)
    % --------- Articulation -------

    fprintf(fid,'<model name="elbow_model">\n');
    fprintf(fid,'\t<pose>%.2f %.4f %.4f 0 0 0</pose>\n', elbow_pos(1), elbow_pos(2), elbow_pos(3));
    fprintf(fid,'\t<static>true</static>\n');
    fprintf(fid,'\t<link name="elbow_link">\n');
    fprintf(fid,'\t\t<pose>0 0 0 0 0 0</pose>\n');
    fprintf(fid,'\t\t<visual name="elbow_visual">\n');
    fprintf(fid,'\t\t\t<geometry><sphere>\n');
    fprintf(fid,'\t\t\t\t<radius>0.005</radius>\n');
    fprintf(fid,'\t\t\t</sphere></geometry>\n');
    fprintf(fid,'\t\t</visual>\n');
    fprintf(fid,'\t</link>\n');
    fprintf(fid,'</model>\n\n');
    % --------- End Articulation ------

    % (joint) link tool to its articulation point for the specified task

    fprintf(fid,['\t<joint name="joint_elbow" type="' elbow_type '">\n']);
    fprintf(fid,'\t\t<parent>tool</parent>\n');
    fprintf(fid,'\t\t<child>elbow_link</child>\n');
    fprintf(fid,'\t\t<axis>\n');
    fprintf(fid,['\t\t\t<xyz>' elbow_axis '</xyz>\n']);
    fprintf(fid,'\t\t\t<use_parent_model_frame>1</use_parent_model_frame>\n');
    fprintf(fid,'\t\t\t<dynamics>\n');
    fprintf(fid,'\t\t\t\t<friction>0.1</friction>\n');
    fprintf(fid,'\t\t\t</dynamics>\n');
    fprintf(fid,'\t\t</axis>\n');
    fprintf(fid,'\t</joint>\n\n');
end

function write_link(fid, link_pose, link_rot,center_mass, mass, write_intertia, inertia, task, sensor_plugin_filename, sensor_plugin_name)
    if strcmp(task,'rolling_dough')
        write_intertia = 0;
    end
    % -------- Link : Tool -----------
    fprintf(fid,'<link name=''tool''>\n');
    fprintf(fid,'\t<pose>%.4f %.4f %.4f %.3f %.3f %.3f</pose>\n',link_pose(1), link_pose(2), link_pose(3), link_rot(1), link_rot(2), link_rot(3));
    fprintf(fid,'\t<inertial>\n');
    fprintf(fid,'\t\t<pose>%.4f %.4f %.4f 0 0 0</pose>\n',center_mass(1),center_mass(2),center_mass(3));
    fprintf(fid,'\t\t<mass>%.4f</mass>\n',mass);
    if write_intertia
        fprintf(fid,'\t\t<inertia>\n');
        fprintf(fid,'\t\t\t<ixx>%.10f</ixx>\n',inertia(1));
        fprintf(fid,'\t\t\t<ixy>0</ixy>\n');
        fprintf(fid,'\t\t\t<ixz>0</ixz>\n');
        fprintf(fid,'\t\t\t<iyy>%.10f</iyy>\n',inertia(2));
        fprintf(fid,'\t\t\t<iyz>0</iyz>\n');
        fprintf(fid,'\t\t\t<izz>%.10f</izz>\n',inertia(3));
        fprintf(fid,'\t\t</inertia>\n');
    end
    fprintf(fid,'\t</inertial>\n');
    fprintf(fid,'\t<collision name=''tool_collision''>\n');
    fprintf(fid,'\t\t<geometry>\n');
    fprintf(fid,['\t\t\t<mesh><uri>model://tool_' task '/tool.dae</uri></mesh>\n']);
    fprintf(fid,'\t\t</geometry>\n');
    fprintf(fid,'\t</collision>\n');
    fprintf(fid,'\t<visual name=''tool_visual''>\n');
    fprintf(fid,'\t\t<geometry>\n');
    fprintf(fid,['\t\t\t<mesh><uri>model://tool_' task '/tool.dae</uri></mesh>\n']);
    fprintf(fid,'\t\t</geometry>\n');
    fprintf(fid,'\t</visual>\n');
    fprintf(fid,'\t<sensor name=''tool_contact'' type=''contact''>\n');
    fprintf(fid,['\t\t<plugin filename="' sensor_plugin_filename '" name="' sensor_plugin_name '" />\n']); %libnail_collision.so" name="nail_collision" />\n');
    fprintf(fid,'\t\t<contact>\n');
    fprintf(fid,'\t\t\t<collision>tool_collision</collision>\n');
    fprintf(fid,'\t\t</contact>\n');
    fprintf(fid,'\t</sensor>\n');
    fprintf(fid,'</link>\n\n'); 
    % --------- End link------------
end
