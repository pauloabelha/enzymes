% https://uk.mathworks.com/help/stats/multivariate-normal-distribution.html
function [ X1, X2, F ] = Plot2DGaussian( mu, Sigma )
    CheckNumericArraySize(mu,[2 1]);
    mu = mu';
    CheckNumericArraySize(Sigma,[2 2]);
    axes_limits_const = 3;
    axes_limits = axes_limits_const*max(Sigma,[],2);
    x1 = linspace(floor(mu(1)-axes_limits(1)),ceil(mu(1)+axes_limits(1)),100);
    x2 = linspace(floor(mu(2)-axes_limits(2)),ceil(mu(2)+axes_limits(2)),100);
    [X1,X2] = meshgrid(x1,x2);
    F = mvnpdf([X1(:) X2(:)],mu,Sigma);
    F = reshape(F,length(x2),length(x1));
    surf(x1,x2,F);
    caxis([min(F(:))-.5*range(F(:)),max(F(:))]);
    %axis([-x1(1) x1(end) -x2(1) x2(end) 0 max(F) + 0.1])
    xlabel('x1'); ylabel('x2'); zlabel('Probability Density');
end

