function [] = NN_Train_Gen(trainDataPath,labelsPath,pcaPath,pcaPathNorm)
%(AFAIK the store files must be created manually before code is run
%Generates the train data and saves it in - trainDataPath. 
%Generates the label data and saves it in - labelsPath
%Generates the PCA data over the train data and saves it in - pcaPath
%Generates the normalised data from the PCA data and saves it in -
%pcaPathNorm 400 is used a treshold cut-point (decided from empirical tests)

 for i = 0.1:0.1:2 
     for j = 0.1:0.1:2
         for k = -1:0.1:1
             %the strange indexing is done so parfor can be applied
             %however it is not tested whether councurrancy creates dissimularities between train and label data 
             for l = -10:1:10 
                 lambdaFinal = [1 1 1 i j 0 0 0 k l/10 0 0 0 0 0];
                 myPcl = SQ2Pcl_Archimedes(lambdaFinal,20000);
                 disp(size(myPcl,1));
                 normals = Get_Normals(myPcl);
                 SH = CalculateSH(myPcl,normals,20000);
                 %Reshape sh,write it to a file as a row vector.
                 dlmwrite(trainDataPath,reshape(SH,1,size(SH,1)*size(SH,2)),'-append','newline','pc'); 
                 dlmwrite(labelsPath,[i,j,k,l/10],'-append','newline','pc'); 
             end
         end
     end  
 end

%coeff stores the coefficients for each principle component linear combination.
%coeff columns are in descending order (aka the first one contains the component which is responsible for most varience)
M = dlmread(trainDataPath,',');
[coeff,~,~] = pca(M);
M = M * coeff(:,1:400);
dlmwrite(pcaPath,M);

%normalise PCA values in column manner. This is done so we normalise our
%histograms bin by bin. E.g. take all values for bin 1 from the test data
%and normalise for those values. Then bin 2,3,4....n
maxmin = max(M) - min(M); % max min takes the max and min from each column and takes their difference (improves speed)
for i=1:size(M,2)
    M(:,i) = (M(:,i)-min(M(:,i)))/(maxmin(1,i)); %maxmin(:,i) 
end
dlmwrite(pcaPathNorm,M); 

end

