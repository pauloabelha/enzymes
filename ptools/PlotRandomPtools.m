% plot a random number n of ptools
function [ plotted_ptools_ixs ] = PlotRandomPtools( ptools, n )
    plotted_ptools_ixs = randi(size(ptools,1),1,n);
    PlotPtools(ptools(plotted_ptools_ixs,:));
end

