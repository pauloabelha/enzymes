function [] = displayPclStruct(P, color)
figure;
scatter3(P.v(:,1), P.v(:,2), P.v(:,3), color); 
axis equal;
end