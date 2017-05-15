function [ P ] = SuperEllipsoidsDemo(  )
    eps_step = 0.5;
    x = 0;
    x_inc = 3;
    y_inc = 3;
    z = 3;
    figure;
    hold on;
    colours = {'.r','.g','.b','.m', '.r','.g','.b','.m'};
    pcl_tot = [];
    normals_tot = [];
    segms = {};
    ix_segm = 0;
    P.u = [];
    for eps1=.1:eps_step:2
        x = x + x_inc;
        y = 0;
        ix_colour = 0;
        for eps2=.1:eps_step:2
            y = y + y_inc;
            ix_colour = ix_colour + 1;
            [pcl, normals] = superellipsoid( [1 1 1 eps1 eps2 0 0 0 0 0 0 0 x y z], 1, colours{ix_colour});
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

