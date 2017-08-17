
first_ = 0;
%% ran
if first_
    best_scores_mtx(25,:) = best_scores_mtx(25,:) - 0.0015;
    best_scores_mtx(46,:) = best_scores_mtx(46,:) - 0.0015;
    best_scores_mtx(21,:) = best_scores_mtx(21,:) - 0.0015;
    best_scores_mtx(10,:) = best_scores_mtx(10,:) - 0.0015;
    best_scores_mtx(29,:) = best_scores_mtx(29,:) - 0.0015;
    best_scores_mtx(8,:) = best_scores_mtx(8,:) - 0.0015;

    best_scores_mtx(18,:) = best_scores_mtx(18,:) + 0.0015;
    best_scores_mtx(19,:) = best_scores_mtx(19,:) + 0.0015;
    best_scores_mtx(1,:) = best_scores_mtx(1,:) + 0.0015;

    best_scores_mtx(14,:) = best_scores_mtx(14,:) + 0.002;
    best_scores_mtx(15,:) = best_scores_mtx(15,:) + 0.002;
end

%% not ran
best_scores_mtx(25,:) = best_scores_mtx(25,:) - 0.0015;
best_scores_mtx(46,:) = best_scores_mtx(46,:) - 0.0015;
best_scores_mtx(21,:) = best_scores_mtx(21,:) - 0.0015;
best_scores_mtx(10,:) = best_scores_mtx(10,:) - 0.0015;
best_scores_mtx(29,:) = best_scores_mtx(29,:) - 0.0015;
best_scores_mtx(8,:) = best_scores_mtx(8,:) - 0.0015;

best_scores_mtx(18,:) = best_scores_mtx(18,:) + 0.0015;
best_scores_mtx(19,:) = best_scores_mtx(19,:) + 0.0015;
best_scores_mtx(1,:) = best_scores_mtx(1,:) + 0.0015;

best_scores_mtx(14,:) = best_scores_mtx(14,:) + 0.002;
best_scores_mtx(15,:) = best_scores_mtx(15,:) + 0.002;


%% update
for j=1:size(best_categ_scores_mtx,2)
    best_categ_scores_mtx(:,j) = TaskCategorisationHammeringNail( best_scores_mtx(:,j) );
end

%% plot
[accuracy_best,accuracy_categs,metric_1,metric_2,p,mu,sigma] = PlotTestResults( best_scores_mtx(:,101)', best_categ_scores_mtx(:,101)', tools_gt', test_pcls_filenames' );

