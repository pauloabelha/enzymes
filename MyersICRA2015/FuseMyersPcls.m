function P = FuseMyersPcls( Ps, theta )

    if ~exist('theta','var')
%         theta = size(Ps,2)*-1.0662e-04;% -0.029 for 272 Ps
        THETA_CONST = 0.02;
        theta = THETA_CONST*272/numel(Ps);
    end

    P = Ps{1};
    tot_toc = 0;
    
%     for i=2:size(Ps,2)
%         tic;
%         rot_z = GetRotMtx((i-1)*theta,'z'); 
%         Ps{i} = Apply3DTransfPCL({Ps{i}},{rot_z});
%         P.v = [P.v; Ps{i}.v];
%         P = DownsamplePCL(P,100000,1);
%         P.segms{1}.v = [P.segms{1}.v; Ps{i}.segms{1}.v];
%         tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(Ps,2));
%     end
%     P.v = P.v(P.v(:,3)<=0.025,:);
    
    for i=2:size(Ps,2)
        tic;
         P = MergePclsMatlab2(P,Ps{i},theta,i-1);
%         P = MergePclsMatlab(P,Ps{i});
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(Ps,2));
    end
    
%     prefix = ['FuseMyersPcls (' num2str(size(Ps,2)) '): '];
%     if size(Ps,2) == 1
%         P = PointCloud(Ps{1}.v);        
%         P = ApplyPCAPCl(P);
%         rot_x = GetRotMtx(pi,'x');
%         P = Apply3DTransfPCL({P},{rot_x});
% %         P.v = P.v(P.v(:,3)>=50,:);
%     else
%         Ps_fused = cell(1,ceil(size(Ps,2)/2));
%         odd_n_of_pcls = mod(size(Ps,2),2);
%         tot_toc = 0;
%         i = 1;
%         ix = 0;
%         ix_plus = 0;
%         while i <= size(Ps,2)
%             ix = ix + 1;            
%             tic;
%             if odd_n_of_pcls && (i == floor(size(Ps,2)/2)+1 || i == size(Ps,2))
%                 Ps_fused{ceil(i/2)} = Ps{i};
%                 i = i + 1;
%                 ix_plus = 1;
%                 continue;
%             else
%                 Ps_fused{ceil(i/2)+ix_plus} = MergePcls(Ps{i},Ps{i+1});
%             end
%             tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,ix,size(Ps_fused,2),prefix);
%             i=i+2;
%         end
%         P = FuseMyersPcls( Ps_fused );
%     end
end

function P = MergePcls(P1,P2)
    % rotate until FitError btw pcls is minimal
    % transform P2 inversely to align with P1
    % downsample bu half
%     P1.v = P1.v - mean(P1.v);
%     P1 = ApplyPCAPCl(P1);
%     P2.v = P2.v - mean(P2.v);
%     P2 = ApplyPCAPCl(P2);
    P1_ds = DownsamplePCL(P1,2000);
    P2_ds = DownsamplePCL(P2,2000);
    
    orig_P2_ds = P2_ds;
    
%     verbose = 'iter';
%     opt_options = optimset('Display',verbose,'TolX',1e-5,'TolFun',1e-10,'MaxIter',1000,'MaxFunEvals',1000);
%     min_lambda = [0 0 0 0];
%     max_lambda = [0.1 0.1 0.1 2*pi];
%     initial_lambda = [0 0 0 pi];
%     [final_lambda,E] = lsqnonlin(@(x) AlignPcls(P1_ds,P2_ds,x), initial_lambda, min_lambda, max_lambda, opt_options );
%     bsxfun(@plus,P2.v,[final_lambda(1:3)]);
%     P2.v = [GetRotMtx(final_lambda(4),'z')*P2.v']';
%     P.v = [P1.v; P2.v];
%     P = DownsamplePCL(P,ceil(size(P.v,1)/2));
    
    min_error = PCLDist(P1_ds.v,P2_ds.v);
    min_ixs = [0 0 0];
    min_theta = 0;
    theta_step = 1/5;
    max_theta = 2*pi;
    n_thetas = 0;
    for theta=0:theta_step:max_theta
        n_thetas = n_thetas + 1;
    end
    errors = [];
    tot_toc = 0;
    ix_x = 0;
    x = 0; y = 0;
%     for x=-0.05:0.01:0.05
%         ix_x = ix_x + 1;
%         tic;
%         for y=-0.05:0.01:0.05
            theta_ix = 0;
            for theta=-0.03:0.01:0.03
                theta_ix = theta_ix + 1;
                P2_ds.v = bsxfun(@plus,orig_P2_ds.v,[x y 0]);
                P2_ds.v = [GetRotMtx(theta,'z')*P2_ds.v']';
                error = PCLDist(P1_ds.v,P2_ds.v);
                errors(end+1) = error;
                if error <= min_error
                    min_error = error;
                    min_theta = theta;
                    min_ixs = [x y theta_ix];
                end
%             end
%         end
%         tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,ix_x,11);
            end
    disp(['Minium theta: ' num2str(min_theta)]);
    P2.v = [GetRotMtx(min_theta,'z')*P2.v']';
    P = PointCloud([P1.v; P2.v]);
    P = DownsamplePCL(P,ceil(size(P.v,1)/2),1);
end

function E = AlignPcls(P1,P2,lambda)
    P2.v = bsxfun(@plus,P2.v,lambda(1:3));
    P2.v = [GetRotMtx(lambda(4),'z')*P2.v']';
    [ ~, ~, ~, ~, ~, E_vec  ] = FitErrorBtwPointClouds(P1.v,P2.v); 
    E = abs(E_vec);
end

function P = MergePclsMatlab(P1,P2)
    gridSize = 0.01;
    mergeSize = 0.003;
    % Use previous moving point cloud as reference.
    fixed = pointCloud(P1.v);
    fixed_ds = pcdownsample(fixed, 'gridAverage', gridSize);
    moving = pointCloud(P2.v);
    moving_ds = pcdownsample(moving, 'gridAverage', gridSize);

    % Apply ICP registration.
    tform = pcregrigid(moving, fixed, 'Metric','pointToPlane','Extrapolate', true);

    % Transform the current point cloud to the reference coordinate system
    % defined by the first point cloud.
    moving = pctransform(fixed, affine3d(tform.T));

    % Update the world scene.
    pcl_merged = pcmerge(fixed, moving, mergeSize);
    P = PointCloud(pcl_merged.Location);
end


function P = MergePclsMatlab2(P1,P2,theta,iter)
    P3 = Apply3DTransfPCL(P2,GetRotMtx(theta*iter,'z'));
    P = PointCloud([P1.v; P3.v]);
%     P = DownsamplePCL(P,size(P2.v,1),1);  
end

