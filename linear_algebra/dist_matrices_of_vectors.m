function [ dist ] = dist_matrices_of_vectors( M1, M2 )
    try
        CheckNumericArraySize(M1,size(M2));
    catch
        dist = Inf;
        return;
    end
    dist = sqrt(sum((M1 - M2).^2,2));
end

