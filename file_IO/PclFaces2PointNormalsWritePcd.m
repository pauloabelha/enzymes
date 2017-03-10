function PlyFaces2PointNormalsWritePcd( P, filepath_pcd )
    meshdataIN.vertices=P.v; 
    meshdataIN.faces = P.f;
    P.n = COMPUTE_mesh_normals(meshdataIN);
    P = PCLFaceNormals2PointNormals( P );
    WritePcd( P, filepath_pcd );
end

