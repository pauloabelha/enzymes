function [] = displaySQs(SQs)

figure;
hold on;
for i=1:length(SQs)
    SQ_pcl = UniformSQSampling3D(SQs{i}, 0, 1000);
    scatter3(SQ_pcl(:,1), SQ_pcl(:,2), SQ_pcl(:,3),50,'.b'); 
    axis equal;
end