
% given a matrix of numbers, get:
% P as the probability of each value
% J as the joint probability of pairs
% P_cond as the conditional probability of pairs

function [ P, J, P_cond ] = GetProbabilities( M, plot_fig )
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    %% get probabilities
    P = zeros(1,max(M(:)));
    M_vec = M(:);
    for i=1:size(M_vec,1)
        P (M_vec(i)) = P (M_vec(i)) + 1;
    end
    P  = P/numel(M_vec);
    %% get joint probabilities
    J = zeros(max(M(:)),max(M(:)));
    n_pairs = 0;
    for i=1:size(M,1)
        for j=1:size(M,2)-1
            for k=j+1:size(M,2)
                n_pairs = n_pairs+1;
                J(M(i,j),M(i,k)) =  J(M(i,j),M(i,k)) + 1;
                J(M(i,k),M(i,j)) = J(M(i,j),M(i,k));
            end
        end
    end    
    J = J/n_pairs;
    %% get conditional probabilities
    P_cond = zeros(max(M(:)),max(M(:)));
    for i=1:size(J,1)
        for j=1:size(J,1)
            if P(j) == 0
                P_cond(i,j) = -1;
            else
                P_cond(i,j) = J(i,j)/P(j);
            end
            if P(i) == 0
                P_cond(j,i) = -1;
            else
                P_cond(j,i) = J(j,i)/P(i);
            end
        end
    end
    %% plot if required
    if plot_fig
        figure;
        plot(P);
        figure;
        surf(1:size(J,1),1:size(J,2),J);
        figure;
        surf(1:size(P_cond,1),1:size(P_cond,2),P_cond);
    end
end

