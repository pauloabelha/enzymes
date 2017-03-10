% based on http://uk.mathworks.com/help/stats/copulafit.html
function [ output_args ] = SampleEmpiricalPDFWithCopulas( D )

    x = D(:,1);
    y = D(:,2);
    
    figure;
    scatterhist(x,y)
    title('Original data');

    u = ksdensity(x,x,'function','cdf');
    v = ksdensity(y,y,'function','cdf');

%     figure;
%     scatterhist(u,v);
%     xlabel('u');
%     ylabel('v'); 
    
    rng default  % For reproducibility
    [Rho,nu] = copulafit('t',[u v],'Method','ApproximateML');
    
    r = copularnd('t',Rho,nu,1000);
    u1 = r(:,1);
    v1 = r(:,2);

    figure;
    scatterhist(u1,v1);
    xlabel('u');
    ylabel('v');
    set(get(gca,'children'),'marker','.');
    
    x1 = ksdensity(x,u1,'function','icdf');
    y1 = ksdensity(y,v1,'function','icdf');

    figure;
    scatterhist(x1,y1)
    set(get(gca,'children'),'marker','.');
    title('Sampled data');


end

