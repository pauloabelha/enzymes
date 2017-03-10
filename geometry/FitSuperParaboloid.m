function [ final_lambdas, Fs, Es, E1s, E2s ] = FitSuperParaboloid( pcl, verbose, plot_fig, pcl_scale, opt_options )
    F=0; E1=0; E2=0;
    n_seeds = 4;

    if exist('verbose','var') && verbose == 1
        verbose = 'iter';
    else
        verbose = 'off';
    end
    
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    
    if ~exist('pcl_scale','var')
        [pcl_scale, pcl] = calculatePCLSegScale( pcl );
    end
        
    initial_scale = pcl_scale/2;
    initial_scale(3) = pcl_scale(3);
    
    min_lambda = [initial_scale*0.8 0.1 -pi -pi -pi min(pcl)];
    max_lambda = [initial_scale*1.05 4 pi pi pi max(pcl)];
    initial_lambdas = zeros(n_seeds,10);    
    initial_power = 0.1;
    initial_lambdas(1,:) = [initial_scale initial_power 0 0 0 mean(pcl(:,1:2)) min(pcl(:,3))];
    initial_lambdas(2,:) = [initial_scale initial_power 0 pi/2 0 min(pcl(:,1)) mean(pcl(:,2:3))];
    initial_lambdas(3,:) = [initial_scale initial_power 0 pi 0 mean(pcl(:,1:2)) max(pcl(:,3))];
    initial_lambdas(4,:) = [initial_scale initial_power 0 -pi/2 0 max(pcl(:,1)) mean(pcl(:,2:3))];  
    
    MIN_PROP_SCALE_FOR_3D = 0.05;
    if min(pcl_scale)/max(pcl_scale) < MIN_PROP_SCALE_FOR_3D
        initial_lambda = initial_lambdas(1,:);
        final_lambda = initial_lambda(1,:);
        E = Inf; E1 = Inf; E2 = Inf;
        return;
    end
    
    min_E_initial = 1e10;
    min_initial_lambda = [];
% OLD BRUTE FORCE
%     for i=1:size(initial_lambdas,1)
%         Es = zeros(1,20);
%         lambda = initial_lambdas(i,:);
%         parfor j=1:20
%             paraboloid_pcl = Paraboloid2PCL([lambda(1:3) j/10 -1 lambda(5:7) 0 0 0 0 lambda(8:10)], size(pcl,1));
%             Es(j) = PCLDist(pcl, paraboloid_pcl);            
%         end
%         [min_Ej, min_Ej_ix] = min(Es);
%         if min_Ej < min_E_initial
%             min_E_initial = min_Ej;
%             min_initial_lambda = [lambda(1:3) min_Ej_ix/5 lambda(5:end)];
%         end
%     end
    if min_E_initial < 0.6
        initial_lambdas(1,:) = min_initial_lambda;
    end
    if ~exist('opt_options','var')
        opt_options = optimset('Display',verbose,'TolX',1e-10,'TolFun',1e-10,'MaxIter',1000,'MaxFunEvals',1000); 
    end
    final_lambdas = zeros(n_seeds,10);
    Es = zeros(1,n_seeds);
    parfor i=1:n_seeds
        [final_lambdas(i,:),Fs(i)] = lsqnonlin(@(x) SuperParaboloidFunction(x, pcl), initial_lambdas(i,:), min_lambda, max_lambda, opt_options  );
    end
    lambdas = zeros(n_seeds,15);
    parfor i=1:n_seeds
        lambdas(i,:) = [final_lambdas(i,1:4) -1 final_lambdas(i,5:7) 0 0 0 0 final_lambdas(i,8:10)];
        paraboloid_pcl = Paraboloid2PCL(lambdas(i,:), size(pcl,1), plot_fig);
        [ Es(i), E1s(i), E2s(i)  ] = PCLDist(paraboloid_pcl,pcl);
    end
    final_lambdas = lambdas;
    if plot_fig
        scatter3(pcl(:,1),pcl(:,2),pcl(:,3),'.k');
        axis equal; hold on;        
        scatter3(pcl(:,1),pcl(:,2),F,'.r'); axis equal;
    end    
end

