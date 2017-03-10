%CHECKISSCALARINRANGE  checks if the input is a scalar within a specified range
%   CheckIsScalarInRange(N,range_spec,range) returns:
%       if N is a scalar and is in the specified range, nothing
%       else, an error
%       
%   range_spec must be one of the following strings:
%       'open-open'
%       'open-closed'
%       'closed-open'
%       'closed-closed'
%
%   range must be a 1*2 array with the inital and end range values
%   function works up to a resolution of 10*eps
%
%   chars are not considered scalars

% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
function CheckScalarInRange( N, range_spec, range )
    if ~exist('N','var')
        error('This function needs an input');
    end
    CheckIsScalar( N );
    CheckNumericArraySize(range,[1 2]);
    new_eps = 10*eps;
    orig_range = range;
    switch range_spec
        case 'open-open'
            range(1) = range(1) + new_eps;
            range(2) = range(2) - new_eps;            
        case 'open-closed'
            range(1) = range(1) + new_eps; 
            range(2) = range(2) + new_eps;
        case 'closed-open'
            range(1) = range(1) - new_eps; 
            range(2) = range(2) - new_eps; 
        case 'closed-closed'
            range(1) = range(1) - new_eps; 
            range(2) = range(2) + new_eps; 
        otherwise
            error('Second param ''range_spec'' needs to specify a valid range type. See help');
    end
    if N < range(1) || N > range(2)
        error(['Scalar ' num2str(N) ' is not in the specified range ' num2str(orig_range(1)) ' to ' num2str(orig_range(2)) ' (' range_spec  ')'  ]);
    end
end

