


function [ sampled_ptools ] = FilterSampledPTools( ptools, sampled_ptools )

%     mins = zeros(1,n_dims_ptools);
%     mins(1:3) = 0.0001;
%     mins(4:5) = 0.1;
%     mins(6:7) = -1;
%     mins(8:10) = 0.0001;
%     mins(11:12) = 0.1;
%     mins(13:14) = -1;
%     mins(15:17) = -1;
%     mins(18) = 0;
%     mins(19:21) = -pi;
%     mins(22) = 0.001;
%     mins(23) = 0.001;
%     
%     maxs = zeros(1,n_dims_ptools);
%     maxs(1:3) = 0.5;
%     maxs(4:5) = 2;
%     maxs(6:7) = 1;
%     maxs(8:10) = 0.25;
%     maxs(11:12) = 2;
%     maxs(13:14) = 1;
%     maxs(15:17) = 1;
%     maxs(18) = pi;
%     maxs(19:21) = pi;
%     maxs(22) = 0.5;
%     maxs(23) = 1; 
%     
    mins = min(ptools);
    maxs = max(ptools);
    
    ixs = true(size(sampled_ptools,1),1);
    for j=1:size(ptools,2)
        ixs = ixs & sampled_ptools(:,j) >= mins(j) & sampled_ptools(:,j) <= maxs(j);
    end
    sampled_ptools = sampled_ptools(ixs,:);
end

