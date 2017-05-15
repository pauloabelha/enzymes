function [ P ] = SegmentPCLWithLine( P, a, b, c, abscissa, ordinate )
    
    P.v(:,ordinate) = P.v(:,ordinate) + c;
    [pts_left, ixs] = clean_pcl_with_linear_function( P.v, 'cut_left', a, b, abscissa, ordinate);
    segms{1} = pts_left;
    segms{2} = P.v(~ixs,:);
    
    P.segms = {};
    P.u = zeros(size(P.v,1),1);
    prev = 0;
    new_points = zeros(size(P.v,1),3);
    for j=1:numel(segms)
        P.segms{end+1}.v = segms{j};
        P.u(prev+1:prev+size(segms{j},1)) = j;
        new_points(prev+1:prev+size(segms{j},1),:) = segms{j};
        prev = prev + size(segms{j},1);
    end     
    P.v = new_points;
    P = AddColourToSegms(P);
end

