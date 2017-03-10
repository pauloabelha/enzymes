function [ pcl_filenames, best_output_scores, best_pTool_vecs ] = GetBestOutputPerTool( pTools, pTool_vecs, output_scores )
    pcl_filenames = {};
    for i=1:size(pTools,2)
        pcl_found=0;
        for j=1:size(pcl_filenames,2)
            if strcmp(GetPCLShortName(pTools{i}{1}.name),pcl_filenames{j})
                pcl_found=1;
                break;
            end            
        end
        if ~pcl_found
            pcl_filenames{end+1} = GetPCLShortName(pTools{i}{1}.name);  
        end
    end
    pTools = flatten_cell(pTools);
    best_output_scores = zeros(size(pcl_filenames,2),1);
    best_pTool_vecs = zeros(size(pcl_filenames,2),size(pTool_vecs,2));
    ix=1;
    tot_toc=0;
    for i=1:size(pcl_filenames,2)
        tic;
        best_output = 1e-10;        
        while ix <= size(pTools,2) && strcmp(GetPCLShortName(pTools{ix}.name),pcl_filenames{i})            
            curr_output = output_scores(ix);
            if curr_output > best_output
                best_output = curr_output;    
                best_pTool_vec = pTool_vecs(ix,:);
            end
            ix=ix+1;
        end
        best_output_scores(i) = best_output;
        best_pTool_vecs(i,:) = best_pTool_vec;  
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(pcl_filenames,2));
    end
end

