function [ chain_rank_scores, chain_dist_scores, chain_angle_scores ] = SumChainScores(source_tool,n_parts,pcls,fitting_ranked_scores)
    %get parts from model
    [~, angles, distances, weights] = SHAPEparam(source_tool);
    segm_ix=1;
    for mode=1:size(pcls,2)        
        segm=1;
        while segm<=size(pcls{mode}{2},2)
            if ~isempty(pcls{mode}{2}{segm}) && ~isempty(pcls{mode}{2}{segm}{1})
                for part=1:size(pcls{mode}{2}{segm}{2},2)
                    Fm{part,segm_ix} = pcls{mode}{2}{segm}{2}{part}{1};
                    Sm{part,segm_ix} = pcls{mode}{2}{segm}{2}{part}{3};
                    mode_segm{segm_ix} = [mode segm];
                end
            end
            segm=segm+1;
            segm_ix=segm_ix+1;
        end
    end
    
    initial_chain = ones(n_parts,1);
    [ chain_rank_scores, chain_dist_scores, chain_angle_scores ] = findMinimumScoreChain(angles,distances,weights,1,Fm,Sm,n_parts,initial_chain,[],[],[] );
    %do a ranked voting od dist scores and angle scores
end 