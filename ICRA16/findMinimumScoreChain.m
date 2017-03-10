function [  chain_size_score, chain_prop_score, chain_fit_scores, chain_dist_scores, chain_angle_vec_parts_z_scores, chain_angle_center_parts_score  ] = findMinimumScoreChain( task_functions, scales, angles,distances,weights,part,Fm,Sm,n_parts,parent_chain,chain_size_score,chain_prop_score,chain_fit_scores,chain_dist_scores,chain_angle_vec_parts_z_scores,chain_angle_center_parts_score )
    if part == n_parts+1
        return;
    end   
    for segment=1:size(Fm,2)
        parent_chain(part) = segment; 
        [pair_size_score, pair_prop_score,pair_fit_score,pair_dist_score,pair_angle_vec_parts_z_score,pair_angle_center_parts_score] = calculatePair(task_functions, scales, angles,distances,weights,Fm,Sm,parent_chain,part-1);
        if part > 1
            if parent_chain(1) == parent_chain(2)
                chain_size_score(parent_chain(1),parent_chain(2)) = Inf;
                chain_prop_score(parent_chain(1),parent_chain(2)) = Inf;
                chain_fit_scores(parent_chain(1),parent_chain(2)) = Inf;
                chain_dist_scores(parent_chain(1),parent_chain(2)) = Inf;
                chain_angle_vec_parts_z_scores(parent_chain(1),parent_chain(2)) = Inf; 
                chain_angle_center_parts_score(parent_chain(1),parent_chain(2)) = Inf; 
            else
                chain_size_score(parent_chain(1),parent_chain(2)) = pair_size_score;
                chain_prop_score(parent_chain(1),parent_chain(2)) = pair_prop_score;
                chain_fit_scores(parent_chain(1),parent_chain(2)) = pair_fit_score;
                chain_dist_scores(parent_chain(1),parent_chain(2)) = pair_dist_score;
                chain_angle_vec_parts_z_scores(parent_chain(1),parent_chain(2)) = pair_angle_vec_parts_z_score; 
                chain_angle_center_parts_score(parent_chain(1),parent_chain(2)) = pair_angle_center_parts_score;                 
            end
        end
        [chain_size_score,chain_prop_score,chain_fit_scores,chain_dist_scores,chain_angle_vec_parts_z_scores,chain_angle_center_parts_score] = findMinimumScoreChain(task_functions, scales, angles,distances,weights,part+1,Fm,Sm,n_parts,parent_chain,chain_size_score,chain_prop_score,chain_fit_scores,chain_dist_scores,chain_angle_vec_parts_z_scores,chain_angle_center_parts_score);             
    end
end


