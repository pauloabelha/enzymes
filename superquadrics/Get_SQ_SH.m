function SQ_SH = Get_SQ_SH( SQ, n_points, flag_plot )
    [SQ_mtx,SQ_normals] = getSQPlotMatrix(SQ,n_points,15);
    SQ_SH = CalculateSH( SQ_mtx, SQ_normals, flag_plot );
end

