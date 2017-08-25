function [ interleave ] = interleave( A, B )
    interleave = [A; B];
    interleave = reshape(interleave,size(interleave,2)*2,1);
end

