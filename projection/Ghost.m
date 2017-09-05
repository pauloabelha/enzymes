function [ ghost_scores, ghost_scores_categ, tools_gt_categ, tool_names, accuracy_best,accuracy_categs,metric_1,metric_2,p,mu,sigma ] = Ghost( test_folder, task, acc_per_categ )
    [ tool_names, ~, tools_gt_categ ] = ReadGroundTruth([test_folder 'groundtruth_' task '.csv']);
    tools_gt_categ = tools_gt_categ';
    ghost_scores = GenerateGTScores(tools_gt_categ,task,acc_per_categ);
    ghost_scores_categ = TaskCategorisation(ghost_scores,task);
    [accuracy_best,accuracy_categs,metric_1,metric_2,p,mu,sigma] = PlotTestResults( ghost_scores, ghost_scores_categ, tools_gt_categ, tool_names, 0);
    close all;
end

function ghost_scores = GenerateGTScores(tools_gt_categ, task, acc_per_categ)
    [~, a, b, c, d] = TaskCategorisation( [], task );
    N = 1e4;
    gen = randi(round(d*1e5),1,N)/1e5;
    scores = zeros(4,N);
    scores(1,1:numel(gen(gen<a))) = gen(gen<a);
    scores(2,1:numel(gen(gen>a & gen<b))) = gen(gen>a & gen<b);
    scores(3,1:numel(gen(gen>b & gen<c))) =  gen(gen>b & gen<c);
    scores(4,1:numel(gen(gen>c))) =  gen(gen>c);
    ixs_scores = [1 1 1 1];
    ghost_scores = zeros(1,numel(tools_gt_categ));
    curr_accs = [-1 -1 -1 -1];
    for i=1:4
        ixs_rnd = randsample(size(tools_gt_categ,2),size(tools_gt_categ,2),'false');
        n_i = 0;
        n_is = size(tools_gt_categ(tools_gt_categ==i),2);
        for k=1:numel(tools_gt_categ)            
            j = ixs_rnd(k);
            if tools_gt_categ(j) == i
                ghost_scores(j) = scores(i,ixs_scores(i));
                ixs_scores(i) = ixs_scores(i) + 1;
                n_i = n_i + 1;
                curr_accs(i) = n_i/n_is;
            end
            if curr_accs(i) >= acc_per_categ(i)
                ghost_scores(j) = 0;
                break;
            end
        end
    end
    for i=1:numel(ghost_scores)
        if ghost_scores(i) == 0
            categ = tools_gt_categ(i);
            if categ == 1 
                ghost_scores(i) = scores(categ+randi(2,1),ixs_scores(categ));
            elseif categ == 2
                if randi(2,1) == 1
                    pm = -1;
                else
                    pm = 1;
                end
                ghost_scores(i) = scores(categ+pm,ixs_scores(categ));
            elseif categ == 3
                if randi(2,1) == 1
                    pm = -1;
                else
                    pm = 1;
                end
                ghost_scores(i) = scores(categ+pm,ixs_scores(categ));
            else
                ghost_scores(i) = scores(categ-randi(2,1),ixs_scores(categ));
            end
            ixs_scores(categ) = ixs_scores(categ) + 1;
        end
    end
end
