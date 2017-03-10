function [ mse, lambda_inits, SQs ] = TestPCL2SQ( plot_in )
    if nargin > 0
        plot = plot_in;
    else
        plot = 0;
    end
    lambda_inits = {};
    SQs = {};
    scale_step = 10;
    epsilon_step = 1;
    angle_step = pi;
    taper_step = 1;
    sum_mse = 1;
    n_fits = 0;
    tic
    for a1=1:scale_step:10
        for a2=1:scale_step:10
            for a3=1:scale_step:10
                for e1=0.1:epsilon_step:2
                    for e2=0.1:epsilon_step:2
                        for eul2=0:angle_step:pi
                            for eul3=0:angle_step:pi
                                for Kx=-1:taper_step:1
                                    for Ky=-1:taper_step:1
                                        lambda_init = [a1 a2 a3 e1 e2 0 eul2 eul3 Kx Ky 0 0 0 0 0];
                                        pcl = UniformSQSampling3D( lambda_init, 0, 2000);
                                        [SQ,~,mse_sq] = PCL2SQ( pcl, 1, 0, 0, [1 1 1 0 1] );
                                        sum_mse = sum_mse + mse_sq;
                                        lambda_inits{end+1} = lambda_init;
                                        SQs{end+1} = SQ{1};
                                        n_fits=n_fits+1;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    mse = sum_mse/n_fits;
    toc
    if plot
        ixs = randsample(1:n_fits,min(n_fits,5));
        for i=1:size(ixs,2)
            SetUpFigure();
            pcl = UniformSQSampling3D( lambda_inits{ixs(i)}, 0, 2000);
            scatter3(pcl(:,1),pcl(:,2),pcl(:,3),'b');
            [SQ_mtx,~] = getSQPlotMatrix(SQs{ixs(i)},4000,15);
            plot3(SQ_mtx(:,1),SQ_mtx(:,2),SQ_mtx(:,3),'y');
        end
    end
end

