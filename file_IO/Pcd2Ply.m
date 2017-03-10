function Pcd2Ply( filepath )
    P = read_pcd( filepath, 1000 );
    filepath(end-2:end) = 'ply';
    WritePly( P, filepath )
end

