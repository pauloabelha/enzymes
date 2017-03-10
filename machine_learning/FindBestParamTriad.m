function [ best_triads, best_score, B_best ] = FindBestParamTriad( start, step, finish, A, B )
    %% search through the 3 params
    size_vector = size(A,1);
    best_triads = [];
    best_score = -Inf;
    lowest_entropy = Inf;
    tot_toc = 0;
    tot_iter = numel(start+step:step:finish );
    ix_tic = 0;
    for i=start+step:step:finish       
        tic;
        ix_tic = ix_tic + 1;
        for j=i+step:step:finish
            for k=j+step:step:finish
                B_categ = categoriseVector(B,i,j,k);
                score = score_vec(A,B_categ,size_vector);
                if score >= best_score
                    best_score = score;
                    best_triads(end+1,:) = [score i j k ];
                    B_entropy = EntropyExpResults(B_categ',2);
                    if B_entropy < lowest_entropy
                        best_score = score;
                        lowest_entropy = B_entropy;
                        B_best = B_categ;
                    end
                end
            end
        end
        tot_toc = DisplayEstimatedTimeOfLoop( tot_toc+toc, ix_tic, tot_iter, 'Finding best param triad: ' );
    end
    best_triads = best_triads(best_triads(:,1) == best_score,2:4);    
end

function score = score_vec(A,B,size_vector)
    %score = abs(sum(A-B))/size_vector;
    %score = size(A(abs(A-B)==0),1)/size_vector;
%     score = 0;
%     for i=1:4
%         score = score + size(A(A==i&B==i),1)/size(A(A==i),1);
%     end
    score = Metric1(B',A');
end

function V = categoriseVector(V,i,j,k)
    for ix=1:size(V,1)
       if V(ix) < i
           V(ix) = 1;
       elseif V(ix) < j
           V(ix) = 2;
       elseif V(ix) < k
           V(ix) = 3;
       else
           V(ix) = 4;   
       end
    end
end

