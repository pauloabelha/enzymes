function [ scaled_pcl, segms ] = ToolScalling( pcl, tool_name, segms )
% Used for rescalling hammers

scaled_pcl=pcl;
max_dim = max(range(scaled_pcl));
switch tool_name
    case 'hammer'        
        while(max_dim<0.25)
            for i=1:size(segms,2)
                segms = segms*10;
            end
            scaled_pcl = scaled_pcl*10;
            max_dim = max(range(scaled_pcl));
        end
        while(max_dim>0.4)
            for i=1:size(segms,2)
                segms = segms/10;
            end
            scaled_pcl = scaled_pcl/10;
            max_dim = max(range(scaled_pcl));
        end
        if max_dim<0.25 || max_dim>0.4
            for i=1:size(segms,2)
                segms = segms/0.3;
            end
            new_scale=max(range(pcl))/0.3;
            scaled_pcl=pcl/new_scale;
        end        
	end
end