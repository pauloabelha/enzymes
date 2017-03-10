function [ pTools_vectors_mat ] = getVectors(pTools)

    pTools_vectors_mat = zeros(size(pTools,2), 23);

    for i= 1:length(pTools)
        pTools_vectors_mat(i,:) = getVector(pTools{i});
    end
end