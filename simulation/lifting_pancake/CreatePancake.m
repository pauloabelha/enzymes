function [ P_pancake ] = CreatePancake( SQ, output_path, plot_fig )
    if SQ
        if ~exist('plot_fig','var')
            plot_fig = 0;
        end

        e1 = 1;
        e2 = 1;
        size_pancake = 0.075;
        cut_height = 0.01;
        lid_size = 0.062;
        lid_thickness = 0.00011;
        colour = [255 255 0]; %yellow

        SQ = [size_pancake/2 size_pancake/2 size_pancake/2 e1 e2 0 0 0 1 1 0 0 0 0 0];
        [P_pancake_top.v, P_pancake_top.n] = UniformSQSampling3D(SQ, 1, 100000);
        P_pancake_top.v = P_pancake_top.v(P_pancake_top.v(:,3)>=cut_height,:);
        P_pancake_top.n = P_pancake_top.n(P_pancake_top.v(:,3)>=cut_height,:);

        SQ = [lid_size lid_size lid_thickness e1 e2 0 0 0 0 0 0 0 0 0 cut_height];
        %[P_lid.v, P_lid.n] = UniformSQSampling3D(SQ, 1, 20000);

        %P_pancake.v = [P_pancake_top.v; P_lid.v];
        %P_pancake.n = [P_pancake_top.n; P_lid.n];

        P_pancake = AddColourToSegms(P_pancake_top,colour);

        Ry = GetRotMtx(pi,'y');
        P_pancake = Apply3DTransfPCL({P_pancake},{Ry});

        WritePly(P_pancake,[output_path 'pancake.ply']);

        if plot_fig
            PlotPCLSegments(P_pancake)
        end
    else
        pancake_size_x = 0.05;
        pancake_size_y = 0.025;
        pancake_attack_angle = pi/4;
        pancake_height = 0.02;
        % construct base
        pts = zeros(8,3);
        pts(1,:) = [-pancake_size_x/2 -pancake_size_y/2 0];
        pts(2,:) = [-pancake_size_x/2 pancake_size_y/2 0];
        pts(3,:) = [pancake_size_x/2 pancake_size_y/2 0];
        pts(4,:) = [pancake_size_x/2 -pancake_size_y/2 0];
        % construct top
        dist_y = pancake_size_y/2 + tan(pancake_attack_angle)*pancake_height;
        pts(5,:) = [-pancake_size_x/2 -dist_y pancake_height];
        pts(6,:) = [-pancake_size_x/2 pancake_size_y/2 pancake_height];
        pts(7,:) = [pancake_size_x/2 pancake_size_y/2 pancake_height];
        pts(8,:) = [pancake_size_x/2 -dist_y pancake_height];
        % bottom faces
        faces(1,:) = [1 2 3];
        faces(2,:) = [1 3 4];
        % left side faces
        faces(3,:) = [5 2 1];
        faces(4,:) = [2 5 6];
        % right side faces
        faces(5,:) = [7 4 3];
        faces(6,:) = [4 7 8];
        % back faces
        faces(7,:) = [6 3 2];
        faces(8,:) = [3 6 7];
        % front faces
        faces(9,:) = [1 4 5];
        faces(10,:) = [8 5 4];
        % top faces
        faces(11,:) = [7 6 5];
        faces(12,:) = [8 7 5];
        % properly indexed
        faces = faces - 1;
        % save in P struct        
        P_pancake.v = pts;
        P_pancake.f = faces;
        P_pancake.n = zeros(size(P_pancake.v));
        % rotate for simulation (-90 degrees around Z)
        Rz = GetRotMtx(-pi/2,'z');
        P_pancake = Apply3DTransfPCL({P_pancake},{Rz});
        % save to file
        WritePly(P_pancake,[output_path 'pancake.ply']);
    end
end

