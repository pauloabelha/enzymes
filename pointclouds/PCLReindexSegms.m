function [ P ] = PCLReindexSegms( P, new_ixs )
    set_U = unique(P.u);
    if numel(new_ixs) ~= numel(set_U)
        error('New indexes must have same number of elements as P.u');
    end
    P_u = P.u;
    for i=1:numel(set_U)
        P_u(P.u==set_U(i)) = i+numel(set_U) - 1;
    end
    P.u = P_u;
    for i=1:numel(set_U)
        P.u(P.u==i+numel(set_U)-1) = new_ixs(i);
    end
end

