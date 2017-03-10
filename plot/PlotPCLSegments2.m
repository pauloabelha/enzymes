function PlotPCLSegments2( segments, color_option )    
    switch color_option
        case -1
            pcl_colours = {'m' 'm' 'm'};
        case 1
            pcl_colours = {'r' 'g' 'y'};
        case 2
            pcl_colours = {'y' 'm' 'c' '.w'};
        case 3
            pcl_colours = {'.w' '.k' '.w' 'k'};
    end
    pcl_colours_ix = 1;
    for i=1:size(segments,2)
        if ~isempty(segments{i})
            scatter3(segments{i}{1}(:,1),segments{i}{1}(:,2),segments{i}{1}(:,3),10,pcl_colours{min(6,pcl_colours_ix)});
            pcl_colours_ix=pcl_colours_ix+1;
        end
    end
end



