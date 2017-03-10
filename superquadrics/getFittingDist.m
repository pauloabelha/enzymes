function [size_score,prop_score,fit_score,dist_score,angle_vec_parts_z_score,angle_center_parts_score] = getFittingDist( task_functions, scales, angles, distances, weights, pair, lambda_a, fit_score_a, lambda_b, fit_score_b)
    
    size_score = 0;    
    for i=1:3
        size_score_1 = ScoreFunction( task_functions.size{1,i}, task_functions.size_score{1,i}, scales{pair}(i), lambda_a(i) );
        size_score_2 = ScoreFunction( task_functions.size{2,i}, task_functions.size_score{2,i}, scales{pair+1}(i), lambda_b(i) );
        size_score = size_score + size_score_1 + size_score_2;
    end
    size_score = weights{pair}(1)*size_score;

    prop_score_a = ShapeScaleProportionScore( task_functions.shape_proportion{pair}, task_functions.shape_proportion_score,pair, scales{pair}, lambda_a(1:3) );
    prop_score_b = ShapeScaleProportionScore( task_functions.shape_proportion{pair+1}, task_functions.shape_proportion_score,pair+1, scales{pair+1}, lambda_b(1:3) );
    prop_score = prop_score_a+prop_score_b;
    prop_score = weights{pair}(2)*prop_score;

    fit_score = fit_score_a + fit_score_b;
    fit_score = weights{pair}(3)*fit_score;

    %get the angles: canonical and lower and upper bounds
    model_best_angle_vec_parts_z= angles{pair}{1};
    model_best_angle_center_parts = angles{pair}{4};
    
    %get the distances: canonical and lower and upper bounds
    model_best_dist= distances{pair}{1};
    
    %get angle and position for lambdas a and b
    lambda_a_ang = [lambda_a(6), lambda_a(7), lambda_a(8)];
    lambda_a_pos = [lambda_a(end-2),lambda_a(end-1),lambda_a(end)];     
    lambda_b_ang = [lambda_b(6), lambda_b(7), lambda_b(8)];
    lambda_b_pos = [lambda_b(end-2),lambda_b(end-1),lambda_b(end)]; 
    
    %get difference in distance
    
     
%     dist_score = 1/abs(fit_dist-model_best_dist);
%     if dist_score < 0
%         dist_score = 1/(dist_score)^2;
%     else
%         dist_score = (dist_score)^2;
%     end
%     dist_score = abs(fit_dist-model_best_dist);
%     dist_score = dist_score*weights{pair}(4);
    fit_dist = pdist([lambda_a_pos; lambda_b_pos]);
    dist_score = ScoreFunction( task_functions.distance, task_functions.distance_score, model_best_dist, fit_dist );
    dist_score = dist_score*weights{pair}(4);

%     dist_score = gaussmf(fit_dist,[model_best_dist/2 model_best_dist]);
%     dist_score = abs(dist_score-1);
%     %check boundaries for distance
%     if fit_dist < distances{pair}{2} || fit_dist > distances{pair}{3}
%         dist_score = Inf;       
%     end    
    
    %get difference in angle
    lambda_a_ang = mod(lambda_a_ang,pi);
    lambda_b_ang = mod(lambda_b_ang,pi);
    vector_lambda_a_Z = eul2rotm_(lambda_a_ang,'ZYZ')*[1;1;1];
    %vector_lambda_a_Z = vector_lambda_a_Z/norm(vector_lambda_a_Z);
    vector_lambda_b_Z = eul2rotm_(lambda_b_ang,'ZYZ')*[1;1;1];
    %vector_lambda_b_Z = vector_lambda_b_Z/norm(vector_lambda_b_Z);
    fit_angle_vec_parts_z = subspace(vector_lambda_a_Z,vector_lambda_b_Z);
    
    fit_angle_vec_parts_z = ScoreFunction( task_functions.angle_z, task_functions.angle_z_score, model_best_angle_vec_parts_z, fit_angle_vec_parts_z );
    fit_angle_vec_parts_z = fit_angle_vec_parts_z*weights{pair}(5);
    
    angle_vec_parts_z_score = fit_angle_vec_parts_z;
    %angle_vec_parts_z_score = abs(model_best_angle_vec_parts_z-fit_angle_vec_parts_z)^2;
    
%     angle_vec_parts_z_score = gaussmf(fit_angle_vec_parts_z,[model_best_angle_vec_parts_z/2 model_best_angle_vec_parts_z]);
%     angle_vec_parts_z_score = abs(angle_vec_parts_z_score-1);
    
    if fit_dist < 0.001
        fit_angle_center_parts = 1e10;
        angle_center_parts_score = 1e10;
    else
        vec_between_center_parts = (lambda_b(end-2:end) - lambda_a(end-2:end))';
        %fit_angle_center_parts = vec_between_center_parts / norm( vec_between_center_parts );
        fit_angle_center_parts = subspace(eul2rotm_(lambda_a_ang,'ZYZ')*[0;0;1],vec_between_center_parts);
    %     inverted_vector_lambda_a_Z = makehgtform('axisrotate',cross(vec_between_center_parts,vector_lambda_a_Z),pi)*[vector_lambda_a_Z; 1];
    %     inverted_vector_lambda_a_Z = inverted_vector_lambda_a_Z(1:3);
    %     fit_angle_center_parts_inverted = subspace(inverted_vector_lambda_a_Z,vec_between_center_parts);
    %     fit_angle_center_parts = min(fit_angle_center_parts,fit_angle_center_parts_inverted);
        angle_center_parts_score = ScoreFunction( task_functions.angle_center, task_functions.angle_center_score, model_best_angle_center_parts, fit_angle_center_parts );
        angle_center_parts_score = angle_center_parts_score*weights{pair}(6);
    end
    
    
    %angle_center_parts_score = fit_angle_center_parts;
    %angle_center_parts_score = 0;
%     angle_center_parts_score = gaussmf(fit_angle_center_parts,[model_best_angle_center_parts/2 model_best_angle_center_parts]);
%     angle_center_parts_score = abs(angle_center_parts_score-1);
    
    
%     %check boundaries for angle
%     if angle_diff < angles{pair}{2} || angle_diff > angles{pair}{3}
%         angle_score = Inf;       
%     else
%         angle_score = pdist([mod(angle_diff,pi); mod(angle_difference,pi)]);
%     end
    
    
    %get final fitting distance
    %fittingDist = weight_ranking_a*score_a + weight_ranking_b*score_b + weight_dist*dist_dist + weight_angle*angle_dist;
end

