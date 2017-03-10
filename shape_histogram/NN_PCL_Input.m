function [nnInput] = NN_PCL_Input(pcl,normals,pcaMatrix,normDiff,normMin)
%NN_PCL_INPUT Takes a pointcloud as input, builds a SH,reshapes it,
%applies PCA on the SH, normalises SH values and returns the outcome
%normDiff and normMin are stored in files otherwise one would have to read
%the whole train data and then evaluate them which takes a lot of time
%thus it is better to do this work before hand to enable faster runtimes.
%normDiff and normMin are row vectors

%currently the NN was trained with 10000 as a cap for downsampling
SH = CalculateSH(pcl,normals,10000);
SH = reshape(SH,1,size(SH,1)*size(SH,2)); %reshape SH to 1x400 row vector
SH = SH * pcaMatrix; 
%normalise each column of the row vector
for i=1:size(SH,2)
    SH(1,i) = SH(1,i) - normMin(1,i) / normDiff(1,i); 
end
nnInput = SH;
end

