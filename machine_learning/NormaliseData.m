function D = NormaliseData( D )
    for j=1:size(D,2)
        if ( max(D(:,j)) - min(D(:,j)) ) == 0
            warning('Dividing by 0 when normalising data');
        end
        D(:,j) = (D(:,j) - min(D(:,j))) ./ ( max(D(:,j)) - min(D(:,j)) );        
    end
    if numel(D(isnan(D))) > 0 || numel(D(isinf(D))) > 0
        warning('Got NaN or Inf when normalising data');
    end
end

