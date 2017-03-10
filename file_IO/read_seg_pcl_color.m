function [orig_pcl,segms] = read_seg_pcl_color(filename)

fid = fopen(filename);
if fid == -1
    msg = strcat('Could not find a *.ply point cloud in: ',filename);
    error(msg);
end
tline = fgetl(fid);

n_points = 0;
i = 1;
while ischar(tline)   
    if length(tline) > 15 && strcmp(tline(1:14),'element vertex')
        n_points = str2num(tline(16:length(tline)));
    end    
    if strcmp(tline,'end_header')
        start_points = i + 1;
        break;
    end    
    tline = fgetl(fid);
    i = i + 1;
end
fclose(fid);

orig_pcl = dlmread(filename, ' ', [start_points 0 n_points 9]);
seg_colours = orig_pcl(1,end-3:end);
segms{1} = [];
segms{1}(end+1,:) = orig_pcl(1,:);
for i=2:size(orig_pcl,1)
    color_ix = 0;
    for j=1:size(seg_colours,1)
        if isequal(orig_pcl(i,end-3:end),seg_colours(j,:))            
            color_ix = j;
            break;
        end
    end    
    if color_ix
        segms{color_ix}(end+1,:) = orig_pcl(i,:);
    else ~color_ix
        seg_colours(end+1,:) = orig_pcl(i,end-3:end);
        segms{end+1} = [];
        segms{end}(end+1,:) = orig_pcl(i,:);
    end
end
end