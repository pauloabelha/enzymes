function [ thin_SQ, scale_sort, scale_sort_ixs ] = IsThinSQ( SQ )
    % min proportion for considering a SQ thin
    MIN_PROP_THIN_SQ = 0.03;
    [scale_sort, scale_sort_ixs] = sort(SQ(1:3),'ascend');
    prop_thin = scale_sort(1)/scale_sort(3);
    thin_SQ = 0;
    if prop_thin <= MIN_PROP_THIN_SQ
        thin_SQ = 1;   
    end
end

