function [ min_lambda, min_pcl_size, max_lambda, max_pcl_size ] = TestSQ2Pcl_Archimedes(  )

    max_v = [-1 -1 -1 -1];
    min_v = [1e10 1e10 1e10 1e10];
    
    epsilon1 = [0.1 1 1.5 2];
        
    tic
    parfor i=1:4
        for m=1:3
            for n=1:3
                for j=0.1:1.9:2
                    for k=-1:1:1
                        for l=-1:1:1
                            a2 = m^2;
                            a3 = n^2;
                            [sq_pcl,time] = SQ2Pcl_Archimedes( [1 a2 a3 epsilon1(i) j 0 0 0 k l 0 0 0 0 0], 0, 'superellipsoid' );
                            n_ = size(sq_pcl,1);
                            if n_ > max_v(i)
                                time
                                max_v(i) = n_;
                                max_pcl{i} = [a2 a3 epsilon1(i) j k l n_];
                            end
                            if n_ < min_v(i)
                                time
                                min_v(i) = n_;
                                min_pcl{i} = [a2 a3 epsilon1(i) j k l n_];
                            end                    
                        end
                    end
                end
            end
        end
    end
        
    toc
    
    [~,min_ix] = min(min_v); 
    min_pcl = cell2mat(min_pcl);
    min_pcl = min_pcl(((min_ix-1)*7)+1:((min_ix-1)*7)+1+6);
    [~,max_ix] = min(max_v); 
    max_pcl = cell2mat(max_pcl);
    max_pcl = max_pcl(((max_ix-1)*7)+1:((max_ix-1)*7)+1+6);
    
    min_lambda = [1 min_pcl(1:4) 0 0 0 min_pcl(5:6) 0 0 0 0 0];
    min_pcl_size = min_pcl(end);
    max_lambda = [1 max_pcl(1:4) 0 0 0 max_pcl(5:6) 0 0 0 0 0];
    max_pcl_size = max_pcl(end);    
end

