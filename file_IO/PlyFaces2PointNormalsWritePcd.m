function PlyFaces2PointNormalsWritePcd( filepath_ply, pcl_scale )
    [P, ~] = ReadPointCloud(filepath_ply);
    P.v = P.v/pcl_scale;
    meshdataIN.vertices=P.v; 
    meshdataIN.faces = P.f;
    P.n = COMPUTE_mesh_normals(meshdataIN);
    P = PCLFaceNormals2PointNormals( P );
    WritePcd( P, strcat(filepath_ply(1:end-3),'pcd'));
end

