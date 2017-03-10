function [ new_scale, scale_option, scale_free ] = changeSQScale( SQ_scale, segm )
    scale_free = 0;
    new_scale = zeros(1,3);
    fixed_scale_params = zeros(1,3);
    n_fixed_scale_params = 0;
    [pcl_scale, A] = calculatePCLSegScale(segm);
    for i=1:3
        has_fixed_scale = 0;
        for j=1:size(SQ_scale,2)
            if SQ_scale(1,j) == i
                has_fixed_scale = 1;
                fixed_scale_params(n_fixed_scale_params+1) = SQ_scale(2,j);
                n_fixed_scale_params=n_fixed_scale_params+1;
                break;                
            end            
        end
        if has_fixed_scale
            new_scale(SQ_scale(1,j)) = SQ_scale(2,j);
        else
            new_scale(i) = pcl_scale(i);
        end       
    end
    if n_fixed_scale_params == 0
        scale_free = 0;
    end
    scale_option = 2;%randi(2);
    if scale_option == 2
        new_scale = pcl_scale(randperm(3));
    end
    if n_fixed_scale_params == 3
         new_scale_old=new_scale;
         new_scale = zeros(1,3);
         [~,new_scale_sorted_ixs] = sort(new_scale_old);
         [~,SQ_sorted_ixs] = sort(fixed_scale_params);
         for i=1:3
             new_scale(SQ_sorted_ixs(i)) = new_scale_old(new_scale_sorted_ixs(i));
         end
    else
        if n_fixed_scale_params == 0
            scale_free = 1;     
        end
    end    
end

