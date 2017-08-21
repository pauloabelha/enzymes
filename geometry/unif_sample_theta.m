function [thetas, thetas1, thetas2] = unif_sample_theta(a, b, eps1, D)
    pi_over_4 = pi/4;
    max_iter = 10^6;
    thetas1(1) = 0;
    i = 0;
    while true
        if i > max_iter
            error(['First theta sampling reach the maximum number of iterations ' num2str(max_iter)]);
        end
        theta_next = update_theta(a, b, eps1, thetas1(end), D);
        new_theta = thetas1(end) + theta_next;
        if new_theta > pi_over_4
            break;
        end
        thetas1(end+1) = new_theta;
        i = i +1;
    end
    thetas2(1) = 0;
%     while true
%         if i > max_iter
%             error(['Second theta sampling reach the maximum number of iterations ' num2str(max_iter)]);
%         end
%         thetas2_next = update_theta(b, a, eps1, thetas2(end), D);
%         new_theta = thetas2(end) + thetas2_next;
%         if new_theta > pi_over_4
%             break;
%         end
%         thetas2(end+1) = new_theta;
%         i = i +1;
%     end
    thetas = [thetas1 pi/2-thetas1];
end