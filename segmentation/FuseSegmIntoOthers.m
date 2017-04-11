function [ P ] = FuseSegmIntoOthers( P, segm_to_fuse_label, verbose )
    P_u_small_ixs = P.u==segm_to_fuse_label;
    P_v_small = P.v(P_u_small_ixs,:);
    P_v_rest = P.v(~P_u_small_ixs,:);
    P_u_rest =  P.u(~P_u_small_ixs);
    dist_neigh = pdist2(P_v_small,P_v_rest);
    [~,dist_neigh_min_xs] = min(dist_neigh,[],2);
    P_u_small = P_u_rest(dist_neigh_min_xs);
    P.u(P_u_small_ixs) = P_u_small;    
    P = PointCloud(P.v,P.n,P.f,P.u);   
end


