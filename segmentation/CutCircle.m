function [ P_in, P_out ] = CutCircle( P, centre, radius )
    DIST = pdist2(P.v,centre);
    in_circle_pts = P.v(DIST<=radius,:);
    P_in = PointCloud(in_circle_pts);
    out_circle_pts = P.v(DIST>radius,:);
    P_out = PointCloud(out_circle_pts);
end

