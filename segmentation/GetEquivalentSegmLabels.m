function [ U, n_labels ] = GetEquivalentSegmLabels( U )
    U_set = unique(U);
    n_labels = numel(U_set);
    for i=1:n_labels
       U(U==U_set(i)) = i;
    end
end

