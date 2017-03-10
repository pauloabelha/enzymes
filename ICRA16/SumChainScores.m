function [ mode_segm, chain_size_score, chain_prop_score, chain_fit_scores, chain_dist_scores, chain_angle_vec_parts_z_scores, chain_angle_center_parts_score ] = SumChainScores(source_tool,n_parts,pcls,task_functions)
    %get parts from model
    [parts, angles, distances, weights] = SHAPEparam(source_tool);
    scales = {};
    for i=1:n_parts
        [lambda_f,~,~,~,~] = SQparam(parts{i},0,0);
        if lambda_f(1,1) == 1
            scales{i} = lambda_f(2,1:3);
        else
            scales{i} = [0 0 0];
        end
    end
    segm_ix=1;
    for mode=1:size(pcls,2)        
        segm=1;
        while segm<=size(pcls{mode}{2},2)
            if ~isempty(pcls{mode}{2}{segm}) && ~isempty(pcls{mode}{2}{segm}{1})
                for part=1:size(pcls{mode}{2}{segm}{2},2)
                    Fm{part,segm_ix} = pcls{mode}{2}{segm}{2}{part}{1};
                    Sm{part,segm_ix} = pcls{mode}{2}{segm}{2}{part}{2}(end);
                    mode_segm{segm_ix} = [mode segm];
                end
            end
            segm=segm+1;
            segm_ix=segm_ix+1;
        end
    end    
    initial_chain = ones(n_parts,1);
    [ chain_size_score, chain_prop_score, chain_fit_scores, chain_dist_scores, chain_angle_vec_parts_z_scores, chain_angle_center_parts_score  ] = findMinimumScoreChain(task_functions,scales,angles,distances,weights,1,Fm,Sm,n_parts,initial_chain,[],[],[],[],[],[]);
end 