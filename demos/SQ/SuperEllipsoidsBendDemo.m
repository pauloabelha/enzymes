function [ P ] = SuperEllipsoidsBendDemo(  )
    a1 = 1;
    a2 = 1;
    a3 = 3;
    eps1 = 1;
    eps2 = 1;
    taperx = 0;
    tapery = 1;
    x = 0;
    x_inc = 4;
    y_inc = 4;
    z = 3;
    figure;
    hold on;
    colours = {'.r','.g','.b','.m', '.r','.g','.b','.m'};
    pcl_tot = [];
    normals_tot = [];
    segms = {};
    ix_segm = 0;
    P.u = [];
    for bend=1:1:3
        x = x + x_inc;
        y = 0;
        ix_colour = 0;
        for tapery=-1:1:1
            y = y + y_inc;
            ix_colour = ix_colour + 1;
            [pcl, normals] = superparaboloid( [a1 a2 a3 eps1 eps2 0 0 0 taperx tapery bend 0 x y z], 1, colours{ix_colour});
            pcl_tot = [pcl_tot; pcl];
            normals_tot = [normals_tot; normals];
            a.v = pcl;
            a.n = normals; 
            segms{end+1} = a;
            P.u = [P.u; zeros(size(pcl,1),1) + ix_segm];
            ix_segm = ix_segm + 1;
        end
    end
    hold off;
    P.v = pcl_tot;
    P.n = normals_tot;
    P.segms = segms;
    P = AddColourToSegms(P);
end

