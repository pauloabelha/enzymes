function [net,tr] = NN_Train(inputs,targets,hiddenLayerSize,checkpoints,checkpointName,epochs)
%Load input and output
% inputs = dlmread('/home/frank/Nikola_GenData/Train_Data/test_simple.txt',',');
inputs = tonndata(inputs,0,0);
%disp(size(inputs,1));
%Output 
% targets = dlmread('/home/frank/Nikola_GenData/Train_Data/labeltest_simple.txt',',');
%The first two columns are scale and are not part of the output
targets = tonndata(targets,0,0);
%disp(size(targets,1));
 
% Create a Fitting Network
%hiddenLayerSize = 10;
net = fitnet(hiddenLayerSize);
% 
% % Set up Division of Data for Training, Validation, Testing
[trainInd,valInd,testInd] = dividerand(size(inputs,2),0.75,0.15,0.1);
%Save the indices for late use
dlmwrite('D:\University\Practicals\Level_4\Dissertation\MR_Files\Indexes\trainInd.txt',trainInd);
dlmwrite('D:\University\Practicals\Level_4\Dissertation\MR_Files\Indexes\valInd.txt',valInd);
dlmwrite('D:\University\Practicals\Level_4\Dissertation\MR_Files\Indexes\testInd.txt',testInd);
% net.divideParam.trainRatio = 70/100;
% net.divideParam.valRatio = 15/100;
% net.divideParam.testRatio = 15/100;
net.divideFcn = 'divideind';
net.divideParam.trainInd = trainInd;
net.divideParam.valInd = valInd;
net.divideParam.testInd = testInd;
net.trainParam.epochs = epochs;
%normalises input data between -1 and 1 (done by default no need to specify)
%net.inputs{1}.processFcns = {'removeconstantrows','mapminmax'};
% Train the Network
if checkpoints
    [net,tr] = train(net,inputs,targets,'useGPU','yes','showResources','yes','useParallel','yes','CheckpointFile',strcat(checkpointName,'.mat'));
else
    [net,tr] = train(net,inputs,targets,'useGPU','yes','showResources','yes','useParallel','yes');
    %[net,tr] = train(net,inputs,targets);
end
 
% Test the Network
tic 
outputs = net(inputs);
disp('Prediction time for whole sample');
disp(toc);
errors = gsubtract(outputs,targets);
performance = perform(net,targets,outputs);

% % View the Network
view(net);
save(strcat(checkpointName,'.mat'),'net');
save(strcat(checkpointName,'_results','.mat'),'tr');