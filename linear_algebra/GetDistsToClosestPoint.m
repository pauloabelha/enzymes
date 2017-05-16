%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% By Paulo Abelha (p.abelha@abdn.ac.uk)
%
% Inputs:
%   points - M * N matrix of N-dimensional points
%   normalise - whether to normalise the data before
%   MAX_EXTRA_MEM - max extra memory to use for function (in bytes)
% Outputs:
%   dists_closest - 1 * M array, for each point, with the distance to its closest point
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ dists_closest, ixs_closest, norm_points ] = GetDistsToClosestPoint( points, normalise, MAX_EXTRA_MEM )
    CheckNumericArraySize(points,[Inf Inf]);
    n_points = size(points,1);
    norm_points = [];
    if exist('normalise','var') && normalise
        norm_points = NormaliseData(points);
        points = norm_points;
    end
    if exist('MAX_MEM','var')
        CheckIsScalar(MAX_EXTRA_MEM);
    else
        MAX_EXTRA_MEM = 8e9;  %1 GB
    end       
    % MATLAB's double is 8 bytes and we need to store an M * M matrix
    EXTRA_MEM_REQUIRED = 8*n_points^2;
    % we also need memory for the identity matrix used to fill the diag of dists
    EXTRA_MEM_REQUIRED = 2*EXTRA_MEM_REQUIRED;
    if EXTRA_MEM_REQUIRED > MAX_EXTRA_MEM
        error(['Not enough memory. Required extra memory is ' num2str(EXTRA_MEM_REQUIRED) ' bytes to fast calculate for ' num2str(n_points) ' points']);
    else
        % get distance matrix
        dists = pdist2(points,points);
        I = eye(n_points,n_points);
        % avoid getting distance from a point to itself
        dists(logical(I)) = Inf;
        clear I;
        [dists_closest,ixs_closest] = min(dists,[],1);
    end
end