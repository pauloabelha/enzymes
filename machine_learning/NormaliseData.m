function D = NormaliseData( D, dim )
    for j=1:size(D,2)
        D(:,j) = (D(:,j) - min(D(:,j))) ./ ( max(D(:,j)) - min(D(:,j)) );        
    end
    D(isnan(D)) = 0;
end

