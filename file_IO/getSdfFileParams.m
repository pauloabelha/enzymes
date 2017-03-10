function [model_name, task_pose_offset, sensor_plugin_filename, sensor_plugin_name, elbow_type, elbow_axis, action_tracker_type, action_tracker_axis, plugin_filename, plugin_name ] = getSdfFileParams(task)
    elbow_type = '';
    elbow_axis = '';
    action_tracker_type = '';
    action_tracker_axis = '';
    switch task
        case 'hammering_nail'
            model_name = 'hammer';
            task_pose_offset = '0 0 0.775'; % If a table was added for example 
            sensor_plugin_filename = 'libnail_collision.so';
            sensor_plugin_name = 'nail_collision';
            elbow_type = 'revolute';            
            elbow_axis = '0 1 0';
            plugin_name = model_name;
            plugin_filename = 'libhammer.so';            
        case 'lifting_pancake'
            model_name = 'lifter';
            task_pose_offset = '0 0 0';
            sensor_plugin_filename = 'libpancake_collision.so';
            sensor_plugin_name = 'pancake_collision';
            elbow_type = 'prismatic';
            elbow_axis = '1 0 0';
            plugin_name = 'lift';
            plugin_filename = 'liblift.so';
        case 'rolling_dough'
            model_name = 'roller';
            task_pose_offset = '0 0 0';
            sensor_plugin_filename = 'libdough_collision.so';
            sensor_plugin_name = 'dough_collision';
            action_tracker_type = 'action_centre';
            action_tracker_axis = '1 0 0';
            plugin_name = 'roll';
            plugin_filename = 'libroll.so';
        case 'cutting_lasagna'
            model_name = 'cutter';
            task_pose_offset = '0 0 0';
            sensor_plugin_filename = 'liblasagna_collision.so';
            sensor_plugin_name = 'lasagna_collision';
            elbow_type = 'prismatic';            
            elbow_axis = '1 0 0';
            action_tracker_type = 'action_bottom';
            action_tracker_axis = '0 1 0';            
            plugin_filename = 'libcut.so';
            plugin_name = 'cut';
        case 'scooping_grains'
            model_name = 'scooper';
            task_pose_offset = '0 0 0';
            sensor_plugin_filename = 'libgrain_collision.so';
            sensor_plugin_name = 'grain_collision';
            elbow_type = 'revolute';            
            elbow_axis = '0 1 0';
            action_tracker_type = 'action_bottom';
            action_tracker_axis = '0 1 0';
            plugin_name = 'scoop';
            plugin_filename = 'libscoop.so';
            
        otherwise
            error(['could not find task ' task]);
    end

end