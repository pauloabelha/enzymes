function GetpToolStatsFromDataset( pTool_vecs )
    figure;
    histogram(pTool_vecs(:,18));
    title('Mass Distribution');
    
    figure;
    histogram(max(pTool_vecs(:,1:3)));
    title('Max grasp size Distribution');
    
    figure;
    histogram(max(pTool_vecs(:,8:10)));
    title('Max action size Distribution');
    
    figure;
    histogram(2^3*pTool_vecs(:,8).*pTool_vecs(:,9).*pTool_vecs(:,10)*10^6);
    title('Volume Distribution (cm^3)');
    
    figure;
    hist3(pTool_vecs(:,15:16)*2); set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    title('Alpha X Beta');
    
    figure;
    hist3(pTool_vecs(:,17:18)*2); set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    title('Distance X Mass');



end

