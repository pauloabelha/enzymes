function [ rgbd, rgb, depth, colour_set ] = MyersReadRGBD( root_folder, tool_name, tool_number, slash )
    if ~exist('slash','var')
        slash = '/';
    end
    prefix_path = [root_folder tool_name slash tool_name '_' tool_number '_'];
    depth_path = [prefix_path 'depth.png'];
    rgb_path = [prefix_path 'rgb.jpg'];
    
    a=strfind(rgb_path,slash);
    img_filename = rgb_path(a(end)+1:end);
    label_path = [rgb_path(1:a(end)) img_filename(1:end-8) '_label.mat'];
    load(label_path); 
    
    rgbd = zeros(480,640,4);
    rgb = imread(rgb_path);
    depth = double(imread(depth_path));
    rgbd(:,:,1:3) = rgb;
    rgbd(:,:,4) = depth;
    
    XYZ = [];
    new_labels = [];
    colours = [];
    colour_dist_eps = 30;
    %% get first colour for colour set
    first_set_colour = -1;
    found_first_set_colour = 0;
    for i=1:size(depth,1)
        for j=1:size(depth,2)
            if gt_label(i,j) > 1e-3 && depth(i,j) >= 1e-3
                first_set_colour = double(reshape(rgb(i,j,:),1,3));
                found_first_set_colour = 1;
                break;
            end
            if found_first_set_colour 
                break;
            end
        end
        if found_first_set_colour
            break;
        end
    end
    colour_set = {first_set_colour};
    segms_pcls = cell(1,1);
    segms_pcls{1}.v = [];
    for i=1:size(depth,1)
        for j=1:size(depth,2)
            if gt_label(i,j) > 1e-3 && depth(i,j) >= 1e-3
                XYZ = [XYZ; i j depth(i,j)];
                new_labels = [new_labels; gt_label(i,j)];
                curr_colour = double(reshape(rgb(i,j,:),1,3));
                found_new_colour = 1;
                closest_set_colour = -1;
                min_colour_dist = Inf;
                ix_found_colour = numel(colour_set)+1;
                for k=1:numel(colour_set)
                    % get colour dist
                    curr_set_colour = colour_set{k}(:)';
                    colour_dist = sum(abs(curr_colour-curr_set_colour))/3;
                    if colour_dist < min_colour_dist
                        min_colour_dist = colour_dist;
                        closest_set_colour = curr_set_colour;
                    end
                    if colour_dist<=colour_dist_eps
                        found_new_colour = 0;
                        ix_found_colour = k;
                        break;
                    end
                    
                end
                if found_new_colour
                    colours = [colours; curr_colour];
                    colour_set{end+1} = curr_colour;
                    segms_pcls{end+1}.v = [i j depth(i,j)];
                else
                    colours = [colours; closest_set_colour];
                    segms_pcls{ix_found_colour}.v = [segms_pcls{ix_found_colour}.v; i j depth(i,j)];
                end
            end
        end
    end    
    
    %% segment by colour
   
    colour_dist_eps = 20;
    for i=1:size(depth,1)
        for j=1:size(depth,2)
            curr_colour = double(reshape(rgb(i,j,:),1,3));
            found_new_colour = 1;
            for k=1:numel(colour_set)
                % get colour dist
                curr_set_colour = colour_set{k}(:)';
                colour_dist = sum(abs(curr_colour-curr_set_colour))/3;
                % if new colour
                if colour_dist<=colour_dist_eps
                    found_new_colour = 0;
                    rgb(i,j,:) = curr_set_colour;
                    break;
                end
            end
            if found_new_colour
                colour_set{end+1} = curr_colour;
            end
        end
    end  
 end

