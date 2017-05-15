function [ pTools_closest, min_dist, ptool_ix, dists ] = FindClosestPTool( pTool, pTool_set, task_name, plot_fig )
    
    pTools_closest = [];
    min_dist = 1e8;
    ptool_ix = 0;
    n_dims = size(pTool,2);
    dists = size(pTool_set,1);
    tot_toc = 0;
    for i=1:size(pTool_set,1)
        tic;
        curr_dist = pdist([pTool(1:n_dims); pTool_set(i,1:n_dims)]);
        dists(i) = curr_dist;
        if curr_dist > 1 && curr_dist < min_dist
            min_dist = curr_dist;
            pTools_closest = pTool_set(i,:);
            ptool_ix = i;
        end
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(pTool_set,1),'Finding closest ptool: ');
    end
    
    if plot_fig
        getPFromPToolVec(pTool,task_name,5000,1);
        getPFromPToolVec(pTools_closest,task_name,5000,1);
    end
    


end

