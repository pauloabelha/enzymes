function SQ_pcl = GetSQPcl( SQ, gamma1, gamma2 )
    cube_pcl = GetCubePcl( 2*max(SQ(1:3)), SQ(end-2:end) );
    F_SQ = SQFunction( SQ, cube_pcl );
    ixs_SQ_surf_0 = F_SQ >= (1-gamma1);
    ixs_SQ_surf_1 = F_SQ < gamma2;
    ixs_SQ_surf = ixs_SQ_surf_0 & ixs_SQ_surf_1;
    SQ_pcl = cube_pcl(ixs_SQ_surf,:);
end

