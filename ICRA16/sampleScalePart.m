function [ ocurr_vec ] = sampleScalePart( scale, segm, part )
    ocurr_vec = [];
    n_filled_options = 0; 
    while n_filled_options<size(scale,1) && ~isempty(scale{n_filled_options+1,part})
        n_filled_options=n_filled_options+1;
    end
    for option=1:n_filled_options              
        for j=1:round(1/scale{option,part}(1))
           ocurr_vec(end+1) = option; 
        end            
    end
end

