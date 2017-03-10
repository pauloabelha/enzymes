function [ sim_ixs, opp_ixs ] = CompareVectors( M1, M2 )
    if size(M1,1) ~= size(M2,1)
        sim_ixs=-1;
        opp_ixs=-1;
        return;
    end
    dist_epsilon=0.1;
    ix_sim_ixs=1;
    opp_sim_ixs=1;
    for i=1:size(M1,1)
        abs_euclid_dist = pdist(abs([M1(i,:); M2(i,:)]));
        if abs_euclid_dist<dist_epsilon
            sim_ixs{ix_sim_ixs}=i;
            ix_sim_ixs=ix_sim_ixs+1;
            if sign(M1(i,1)) == -sign(M2(i,1)) && sign(M1(i,2)) == -sign(M2(i,2)) && sign(M1(i,3)) == -sign(M2(i,3));
                opp_ixs{opp_sim_ixs}=i;
                opp_sim_ixs=opp_sim_ixs+1;
            end
        end        
    end
    sim_ixs = cell2mat(sim_ixs);
    opp_ixs = cell2mat(opp_ixs);
end
