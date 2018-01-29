function [ best_opt_vec, R, avg_dist_pre_align, avg_dist_final ] = StupidMeshAlignment( P, Q, init_opt_vec )
    %% downsample both pcls
    P = DownsamplePCL(P,1000,1);
    Q = DownsamplePCL(Q,1000,1);
    %% perform pre-alignment with PCA
    P_pre = CentralisePCL( P );
    Q_pre = CentralisePCL( Q );
    P_pre = ApplyPCAPCl(P_pre);
    Q_pre = ApplyPCAPCl(Q_pre);
    % rotate Q according to initial optimisation vector      
    Q_pre.v = Q_pre.v + init_opt_vec(1:3);
    rot = GetEulRotMtx(init_opt_vec(4:6));
    Q_pre = Apply3DTransfPCL(Q_pre,rot);    
    %% prepare for optimisation
    % get only the point matrices from the pcls
    pcl1 = P_pre.v;
    pcl2 = Q_pre.v;
    avg_dist_pre_align = StupidMeshAlignemtnOptFunc(init_opt_vec, pcl1, pcl2);
     
    min_pcl1_opt_vec = init_opt_vec - [0.1 0.1 0.1 pi pi pi];
    max_pcl1_opt_vec = zeros(1,6) + [0.1 0.1 0.1 pi pi pi];
    opt_options = optimset('Display','iter','TolX',1e-10,'TolFun',1e-10,'MaxIter',200,'MaxFunEvals',1000);
    [best_opt_vec,~,~,~,~] = lsqnonlin(@(pcl1_opt_vec) StupidMeshAlignemtnOptFunc(pcl1_opt_vec, pcl1, pcl2), init_opt_vec, min_pcl1_opt_vec, max_pcl1_opt_vec, opt_options);
    % translate and rotate Q so it becomes R, the final, aligned pcl (ignoring segments)
    R = Q_pre;
    R.v = R.v + best_opt_vec(1:3);    
    rot = GetEulRotMtx(best_opt_vec(4:6));
    R = Apply3DTransfPCL(R,rot);    
    % calculate final avg dist
    avg_dist_final = StupidMeshAlignemtnOptFunc(best_opt_vec, pcl1, pcl2);
end

function avg_dist = StupidMeshAlignemtnOptFunc(pcl1_opt_vec, pcl1, pcl2)
    transl = pcl1_opt_vec(1:3);
    rot = GetEulRotMtx(pcl1_opt_vec(end-2:end));
    pcl2 = Apply3DTransfPCL(PointCloud(pcl2),rot);
    pcl2 = pcl2.v;
    pcl2 = pcl2 + transl;
    DIST=pdist2(pcl1,pcl2);
    min_dists1to2 = min(DIST,[],1);
    min_dists2to1 = min(DIST,[],2);
    avg_dist = (min_dists1to2' + min_dists2to1)/2;
end
