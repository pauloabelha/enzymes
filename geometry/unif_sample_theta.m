function thetas = unif_sample_theta(a, b, eps1, D)
    pi_over_4 = pi/4;
    max_iter = 10^6;
    thetas(1) = 0;
    i = 0;
    while true
        if i > max_iter
            error(['First theta sampling reach the maximum number of iterations ' num2str(max_iter)]);
        end
        theta_next = update_theta(a, b, eps1, thetas(end), D);
        new_theta = thetas(end) + theta_next;
        if new_theta > pi_over_4
            break;
        end
        thetas(end+1) = new_theta;
        i = i +1;
    end
    thetas2(1) = 0;
    while true
        if i > max_iter
            error(['Second theta sampling reach the maximum number of iterations ' num2str(max_iter)]);
        end
        thetas2_next = update_theta(b, a, eps1, thetas2(end), D);
        new_theta = thetas2(end) + thetas2_next;
        if new_theta > pi_over_4
            break;
        end
        thetas2(end+1) = new_theta;
        i = i +1;
    end
    thetas = [thetas pi/2-thetas2];
end