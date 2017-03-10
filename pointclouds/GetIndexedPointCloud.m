function [ P ] = GetIndexedPointCloud( P, ixs )
    CheckIsPointCloudStruct(P);
    P.v = P.v(ixs,:);
    if ~isempty(P.n)
        P.n = P.n(ixs,:);
    end
    if ~isempty(P.u)
        P.u = P.u(ixs,:);
    end
    if ~isempty(P.c)
        P.c = P.c(ixs,:);
    end
end

