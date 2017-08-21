% https://www.youtube.com/watch?v=50Vgw11qn0o
% Copied from Philipp Hennig
% Modified by Paulo Abelha

%% data
% get Y,X,sigma
data_start = 1;
data_finish = 10;
N = 10;
X = linspace(data_start,data_finish,N)';
Y = LinearPlusNoise(X);
sigma = 1;
%% prior on w
% number of features
F = 2;
% feature function (phi is an NxF matrix)
phi = @(a)(bsxfun(@power,a,0:F-1));
mu = zeros(F,1);
Sigma = eye(F);
%% prior on f(x)
% test points
N = 10;
n = N*10;
x = linspace(data_start,data_finish,n)';
% features of x
phix = phi(x);
% mean of the prior
m = phix * mu;
% covar of the prior
kxx = phix * Sigma * phix';
% samples from prior
s = bsxfun(@plus,m,chol(kxx + 1.0e-8 * eye(n))' * randn(n,3));
% marginal stddev, for plotting
stdpi = sqrt(diag(kxx));
% plot prior
Plot2DGaussian(mu,Sigma);
%% prior on Y = fx + e
% features of data
phiX = phi(X);
M = phiX * mu;
% p(fx) = N(M,kxx)
kXX = phiX * Sigma * phiX';
%% inference
% p(Y) = N(M,kxx+sigma^2*I)
G = kXX + sigma^2 * eye(N);
% O(N^3) step
R = chol(G);
% cov(fx,fX) = kxX
kxX = phix * Sigma * phiX';
% pre-compute for re-use
A = kxX / R;
% p(fx|Y) = N(m+kxX(kXX+sigma^2*I)^-1 *(Y-M))
mpost = m + A * (R' \ (Y-M));
% kxx - kxX(kXX+sigma^2*I)^-1 * kXx)
vpost = kxx - A * A';
% samples
spost = bsxfun(@plus,mpred,chol(vpred + 1.0e-8 * eye(n))' * randn(n,3));
% marginal stddev, for plotting
stdpo = sqrt(diag(vpred));
