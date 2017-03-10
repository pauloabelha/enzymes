function [size_score,prop_score,fit_score,dist_score,angle_vec_parts_z_score,angle_center_parts_score] = calculatePair(task_functions, scales, angles,distances,weights,Fm,Sm,chain,part)
    size_score = 0;
    prop_score = 0;
    fit_score = 0;
    dist_score = 0;
    angle_vec_parts_z_score = 0;
    angle_center_parts_score = 0;
    if part > 0
        lambdas_a = Fm(part,chain(part,1));
        lambdas_b = Fm(part+1,chain(part+1,1));
        lambda_a = lambdas_a{1};       
        lambda_b = lambdas_b{1};
        fit_score_a = Sm(part,chain(part,1));
        fit_score_b = Sm(part+1,chain(part+1,1));
        fit_score_a = fit_score_a{1};
        fit_score_b = fit_score_b{1};
        [size_score,prop_score,fit_score,dist_score,angle_vec_parts_z_score,angle_center_parts_score] = getFittingDist( task_functions, scales, angles, distances, weights, part, lambda_a, fit_score_a, lambda_b, fit_score_b);
    end
end