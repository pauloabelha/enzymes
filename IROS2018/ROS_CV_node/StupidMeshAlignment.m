function [ best_pcl1_opt_vec ] = StupidMeshAlignment( P, Q, init_pcl1_opt_vec )
    P = DownsamplePCL(P,5000,1);
    pcl2 = P.v;
    Q = DownsamplePCL(Q,5000,1);
    pcl1 = Q.v;
    
    transl = init_pcl1_opt_vec(1:3);
    rot = GetEulRotMtx(init_pcl1_opt_vec(end-2:end));
    pcl1 = Apply3DTransfPCL(PointCloud(pcl1),rot);
    pcl1 = pcl1.v;
    pcl1 = pcl1 + transl;
    
    min_pcl1_opt_vec = zeros(1,6) - 0.1;
    max_pcl1_opt_vec = zeros(1,6) + 0.1;
    opt_options = optimset('Display','iter','TolX',1e-10,'TolFun',1e-10,'MaxIter',200,'MaxFunEvals',1000);
    [best_pcl1_opt_vec,~,~,~,~] = lsqnonlin(@(pcl1_opt_vec) StupidMeshAlignemtnOptFunc(pcl1_opt_vec, pcl1, pcl2), [init_pcl1_opt_vec 0 0 0], min_pcl1_opt_vec, max_pcl1_opt_vec, opt_options);
    a=0;
end

function V2 = StupidMeshAlignemtnOptFunc(pcl1_opt_vec, pcl1, pcl2)
    transl = pcl1_opt_vec(1:3);
    rot = GetEulRotMtx(pcl1_opt_vec(end-2:end));
    pcl1 = Apply3DTransfPCL(PointCloud(pcl1),rot);
    pcl1 = pcl1.v;
    pcl1 = pcl1 + transl;
    [ V, V1, V2] = PCLDist( pcl1, pcl2 );
end
