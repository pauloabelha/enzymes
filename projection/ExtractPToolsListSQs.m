function [ ptools, ptools_maps, ixs ] = ExtractPToolsListSQs( SQs, tool_mass )

    % get choices of grap-action (usage) assignments to segments
    n_SQs = size(SQs,2);
    n_ixs = ((n_SQs^2)-n_SQs);
    ixs = zeros(n_ixs,2);
    n = 0;
    for i=1:n_SQs
        for j=i+1:n_SQs
            n = n + 1;
            ixs(n,:) = [i j];
            n = n + 1;
            ixs(n,:) = [j i];
        end
    end
    ptools_struct = cell(1,size(ixs,1));
    ptools_maps = zeros(size(ixs,1),6);
    for i=1:size(ixs,1)
        [ptools_struct{i}, orig_grasp_centre ,orig_vec_grasps] = ExtractPTool(SQs{ixs(i,1)},SQs{ixs(i,2)},tool_mass); 
        ptools_maps(i,:) = [orig_grasp_centre orig_vec_grasps'];
    end
    ptools = AddInertialToPtools( ptools_struct );
end

