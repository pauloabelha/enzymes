function [ sampled_ptools ] = FilterSampledPTools( ptools, sampled_ptools )
    ixs = true(size(sampled_ptools,1),1);
    for j=1:size(ptools,2)
        ixs = ixs & sampled_ptools(:,j) >= min(ptools(:,j)) & sampled_ptools(:,j) <= max(ptools(:,j));
    end
    sampled_ptools = sampled_ptools(ixs,:);
end

