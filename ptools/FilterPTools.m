


function [ ptools ] = FilterPTools( ptools )
    
    mins = zeros(1,size(ptools,2));
    mins(1:3) = 0.0001;
    mins(4) = 0.1;
    mins(5) = -1; % for paraboloid
    mins(6:7) = -1;
    for i=8:14
       mins(i) = mins(i-7); 
    end
    mins(15:17) = 0;
    mins(18:21) = -pi;
    
    maxs = zeros(1,size(ptools,2));
    maxs(1:3) = 0.5;
    maxs(4:5) = 2;
    maxs(6:7) = 1;
    for i=8:14
       maxs(i) = maxs(i-7); 
    end
    maxs(15:17) = 0.5;
    maxs(18:21) = pi;
    
    ixs = true(size(ptools,1),1);
    parfor j=1:size(ptools,2)
        ixs = ixs & ptools(:,j) >= mins(j) & ptools(:,j) <= maxs(j);
    end
    ptools = ptools(ixs,:);
end

