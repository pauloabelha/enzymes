function [ clustered_chains ] = ClusterProjections( projections )         
    n_parts=2;
    clustered_chains = {};
    if projections{1}.n_best_chains > 0
        clustered_chains{1}.n_rep = 0;
        clustered_chains{1}.scores = projections{1}.best_chains{1}.scores;
        for part=1:n_parts
            clustered_chains{1}.part_fits{part} = projections{1}.best_chains{1}.part_fits{part};            
            clustered_chains{1}.part_scores{part} = projections{1}.best_chains{1}.part_scores{part};
        end
    end
    for proj=1:size(projections,2)
        for proj_chains=1:projections{proj}.n_best_chains
            new_chain_found = 0;
            for part=1:n_parts
                SQ_proj = projections{proj}.best_chains{proj_chains}.part_fits{part};
                for clust_ix=1:size(clustered_chains,2)                    
                    SQ_cluster = clustered_chains{clust_ix}.part_fits{part};
                    [equal, ~] = SQ_equal( SQ_proj, SQ_cluster );
                    new_chain_found = ~equal;
                    if equal
                        break;
                    end
                end
                if new_chain_found
                    break;
                end
             end
             if new_chain_found
                 clustered_chains{end+1}.n_rep = 0;
                 clustered_chains{end}.scores = projections{proj}.best_chains{proj_chains}.scores;
                 for part=1:n_parts
                    clustered_chains{end}.part_fits{part} = projections{proj}.best_chains{proj_chains}.part_fits{part};                    
                    clustered_chains{end}.part_scores{part} = projections{proj}.best_chains{proj_chains}.part_scores{part};                    
                 end
             end
        end
    end 
    
    rep_values = zeros(size(clustered_chains,2),1);
    for clust_ix=1:size(clustered_chains,2)   
        min_sum_scores = Inf;
        for proj=1:size(projections,2)
            for proj_chains=1:projections{proj}.n_best_chains                
                for part=1:n_parts
                    SQ_proj = projections{proj}.best_chains{proj_chains}.part_fits{part};
                    SQ_cluster = clustered_chains{clust_ix}.part_fits{part};
                    [equal, ~] = SQ_equal( SQ_proj, SQ_cluster );
                    if ~equal
                        break;
                    end
                end
                if equal
                    clustered_chains{clust_ix}.n_rep=clustered_chains{clust_ix}.n_rep + 1;
                    if sum(projections{proj}.best_chains{proj_chains}.scores) < min_sum_scores
                        min_sum_scores = clustered_chains{clust_ix}.scores;
                        clustered_chains{clust_ix}.scores = projections{proj}.best_chains{proj_chains}.scores;
                        for part=1:n_parts
                            clustered_chains{clust_ix}.part_fits{part} = projections{proj}.best_chains{proj_chains}.part_fits{part};            
                            clustered_chains{clust_ix}.part_scores{part} = projections{proj}.best_chains{proj_chains}.part_scores{part};
                        end                       
                    end
                end
            end
        end
        rep_values(clust_ix) = clustered_chains{clust_ix}.n_rep;
    end
    
    [~,bbb] = sort(rep_values,'descend');
    temp = {};
    for i=1:size(bbb,1)
        temp{bbb(i)} = clustered_chains{i};
    end
    clustered_chains = temp;          
end

function [equal, equal_dim] = SQ_equal( SQ1, SQ2 )
    equal = 1;
    equal_dim = 0;
    scale_epsilon = 1.1;
    shape_epsilon = 0.01;
    angle_epsilon = pi/10;    
    taper_epsilon = 1;
    bend_epsilon = 1;
    pos_epsilon = 0.03;
    
    if abs(SQ1(1)/SQ2(1)) > scale_epsilon || abs(SQ1(2)/SQ2(2)) > scale_epsilon || abs(SQ1(3)/SQ2(3)) > scale_epsilon
      equal = 0;
      equal_dim = 1;
      return;
    end
    
    if abs(SQ1(4)-SQ2(4)) > shape_epsilon || abs(SQ1(5)-SQ2(5)) > shape_epsilon
      equal = 0;
      equal_dim = 2;
      return;
    end
    
    angle_diff = subspace(eul2rotm_(SQ1(6:8),'ZYZ')*[0;0;1],eul2rotm_(SQ2(6:8),'ZYZ')*[0;0;1]);
    angle_diff = mod(angle_diff,pi);
    if angle_diff > angle_epsilon
      equal = 0;
      equal_dim = 3;
      return;
    end
    
    if abs(SQ1(9)-SQ2(9)) > taper_epsilon || abs(SQ1(10)-SQ2(10)) > taper_epsilon
      equal = 0;
      equal_dim = 4;
      return;
    end
    
    if abs(SQ1(11)-SQ2(11)) > bend_epsilon || abs(SQ1(12)-SQ2(12)) > bend_epsilon
      equal = 0;
      equal_dim = 5;
      return;
    end
    
    if abs(SQ1(13)-SQ2(13)) > pos_epsilon || abs(SQ1(14)-SQ2(14)) > pos_epsilon || abs(SQ1(15)-SQ2(15)) > pos_epsilon
      equal = 0;
      equal_dim = 6;
      return;
    end   
end

