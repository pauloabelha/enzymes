function cube_pcl = GetCubePcl( size, pos )
    resolution=20;
    cube_pcl= zeros(resolution^3,3);
    ix=1;
    for i=0:resolution
        x_v = (pos(1)-(size/2))+((i/resolution)*size);
        for j=0:resolution
            y_v = (pos(2)-(size/2))+((j/resolution)*size);
            for k=0:resolution
                z_v = (pos(3)-(size/2))+((k/resolution)*size);
                cube_pcl(ix,:) = [x_v y_v z_v];
                ix=ix+1;
            end
        end
    end
end

