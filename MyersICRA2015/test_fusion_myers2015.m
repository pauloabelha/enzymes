
gridSize = 0.001;
mergeSize = 0.001;

plot_fig = 1;
root_folder = 'C:\Users\r02pa14\Desktop\Myers_dataset\part-affordance-dataset\';
fused_folder = 'fused/';
tools_folder = 'tools/';
segmentation_folder = '';
tool_suffix = '_depth.png';
type_use = 2;
skip_step = 1;
n_folders = 12;

[ folders ] = FindAllFolders( [root_folder tools_folder] );

for f=1:size(folders,2)
    try
        [ folders ] = FindAllFolders( [root_folder tools_folder]);
        [ filenames_type ] = FindAllFilesOfPrefix( '', [root_folder tools_folder folders{f} segmentation_folder] );
        n_shots = size(filenames_type,2)/4;

        tool_prefix = folders{f}(1:end-1);
        tool_numbering = get_tool_numbering_myers2015(1);
        tool_name = [tool_prefix '_' tool_numbering];
        tool_image_filename = [tool_name tool_suffix];
        filepath = [root_folder tools_folder folders{f} segmentation_folder tool_image_filename];
        switch type_use
            case 0
                P = ReadPointCloud(filepath);
                P.v = P.v(P.v(:,3)>0.1,:);
            case 1
                P = ReadPointCloud(filepath);
            case 2
                P = read_png_as_pcl_myers2015(filepath);
            case 3
                [~, P_raw] = read_png_as_pcl_myers2015(filepath);
                P = read_png_as_pclwithtable_myers2015( P_raw );
        end
        
        ptCloudRef = pointCloud(P.v);

        tool_prefix = folders{f}(1:end-1);
        tool_numbering = get_tool_numbering_myers2015(2);
        tool_name = [tool_prefix '_' tool_numbering];
        tool_image_filename = [tool_name tool_suffix];
        filepath = [root_folder tools_folder folders{f} segmentation_folder tool_image_filename];
        switch type_use
            case 0
                P = ReadPointCloud(filepath);
                P.v = P.v(P.v(:,3)>0.1,:);
            case 1
                P = ReadPointCloud(filepath);
            case 2
                P = read_png_as_pcl_myers2015(filepath);
            case 3
                [~, P_raw] = read_png_as_pcl_myers2015(filepath);
                P = read_png_as_pclwithtable_myers2015( P_raw );
        end
        ptCloudCurrent = pointCloud(P.v);



        fixed = pcdownsample(ptCloudRef, 'gridAverage', gridSize);
        moving = pcdownsample(ptCloudCurrent, 'gridAverage', gridSize);

        % Note that the downsampling step does not only speed up the registration,
        % but can also improve the accuracy

        tform = pcregrigid(moving, fixed, 'Metric','pointToPlane','Extrapolate', true);
        ptCloudAligned = pctransform(ptCloudCurrent,tform);


        ptCloudScene = pcmerge(ptCloudRef, ptCloudAligned, mergeSize);

        moving = pcdownsample(ptCloudScene, 'gridAverage', gridSize);

        % Store the transformation object that accumulates the transformation.
        accumTform = tform;
        
        if plot_fig
            figure
            hAxes = pcshow(ptCloudScene, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down');
            title('Updated world scene')
            % Set the axes property for faster rendering
            hAxes.CameraViewAngleMode = 'auto';
            hScatter = hAxes.Children;
        end

        tot_toc = 0;
        for i=3:skip_step:n_shots
            tic;
            tool_prefix = folders{f}(1:end-1);
            tool_numbering = get_tool_numbering_myers2015(i);
            tool_name = [tool_prefix '_' tool_numbering];
            tool_image_filename = [tool_name tool_suffix];
            filepath = [root_folder tools_folder folders{f} segmentation_folder tool_image_filename];
            switch type_use
                case 0
                    P = ReadPointCloud(filepath);
                    P.v = P.v(P.v(:,3)>0.1,:);
                case 1
                    P = ReadPointCloud(filepath);
                case 2
                    P = read_png_as_pcl_myers2015(filepath);
                case 3
                    [~, P_raw] = read_png_as_pcl_myers2015(filepath);
                    P = read_png_as_pclwithtable_myers2015( P_raw );
            end
        %     pcl = P.v;
        %     figure;
        %     scatter3(pcl(:,1),pcl(:,2),pcl(:,3),'.k'); axis equal;
            
            ptCloudCurrent = pointCloud(P.v);

            % Use previous moving point cloud as reference.
            fixed = moving;
            moving = pcdownsample(ptCloudCurrent, 'gridAverage', gridSize);

            % Apply ICP registration.
            tform = pcregrigid(moving, fixed, 'Metric','pointToPlane','Extrapolate', true);

            % Transform the current point cloud to the reference coordinate system
            % defined by the first point cloud.
            accumTform = affine3d(tform.T * accumTform.T);
            ptCloudAligned = pctransform(ptCloudCurrent, accumTform);

            % Update the world scene.
            ptCloudScene = pcmerge(ptCloudScene, ptCloudAligned, mergeSize);

            % Visualize the world scene.
            if plot_fig
                hScatter.XData = ptCloudScene.Location(:,1);
                hScatter.YData = ptCloudScene.Location(:,2);
                hScatter.ZData = ptCloudScene.Location(:,3);
                hScatter.CData = ptCloudScene.Color;
                drawnow('limitrate')
            end
            tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,n_shots,['Fusing Tool: ' tool_prefix ' - ']);
        end

        % During the recording, the Kinect was pointing downward. To visualize the
        % result more easily, let's transform the data so that the ground plane is
        % parallel to the X-Z plane.
        if plot_fig
            angle = -pi/10;
            A = [1,0,0,0;...
                 0, cos(angle), sin(angle), 0; ...
                 0, -sin(angle), cos(angle), 0; ...
                 0 0 0 1];
            ptCloudScene = pctransform(ptCloudScene, affine3d(A));
            pcshow(ptCloudScene, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', ...
                    'Parent', hAxes)
            title('Updated world scene')
            xlabel('X (m)')
            ylabel('Y (m)')
            zlabel('Z (m)')
        end

        P = PointCloud(ptCloudScene.Location);
        % P = ApplyPCAPCl(P);
        % rot_x = GetRotMtx(pi,'x');
        % P = Apply3DTransfPCL({P},{rot_x});
        % P = RemovePlaneRansac(P,'',0.005);
        % P = RemovePlaneRansac(P,'',0.005);
        WritePly(P,[root_folder fused_folder tool_prefix '.ply']);
        close;
    catch
       disp(['Could not fuse tool ' tool_prefix]); 
    end
end