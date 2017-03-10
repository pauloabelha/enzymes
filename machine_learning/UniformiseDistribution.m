% gets values V and make them uniform accros required values ranges R
% by chopping off the minimum ammount
function [ D_unif, ixs ] = UniformiseDistribution( D, V, R, max_prop_diff )
    CheckNumericArraySize(V,[Inf 1]);
    CheckNumericArraySize(R,[Inf 1]);
    R = [0; R];
    if ~exist('max_prop_diff','var')
        max_prop_diff = 1;
    end
    minV_n_pts = 1e10;
    for i=2:size(R,1)
        v_split = V(V> R(i-1) & V<=R(i));
        if size(v_split,1) > 0 && size(v_split,1) < minV_n_pts
            minV_n_pts = size(v_split,1);
        end
    end
    max_pts = minV_n_pts*max_prop_diff;
    ixs = zeros(size(V,1),1);
    for i=2:size(R,1)
        n_sampled_points = 0;
        for j=1:size(V,1)           
            if n_sampled_points <= max_pts
                if V(j)> R(i-1) && V(j)<=R(i)
                    n_sampled_points = n_sampled_points + 1;
                    ixs(j) = 1;
                end
            else
                break;
            end
        end
    end
    ixs = logical(ixs);
    D_unif = D(ixs,:);
end

