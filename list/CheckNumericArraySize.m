%CHECKNUMERICARRAYSIZE  checks if a numeric array has the desired size
%   CheckNumericArraySize(A, desired_dims_sizes) returns:
%       if A is an array and has the desired dimension sizes, nothing
%       else, an error
%
%   Programmed with Matlab's 'size' function in mind
%       i.e. CheckNumericArraySize( A, size(A) ) should pass the test
%   Inputs:
%       A - input to test whether it is a numeric array of desired size
%       desired_dims_sizes - 1 by d array with the sizes for each dimension
%           if this param is not given, A just needs to be a numeric array
%           if this param is empty, A must be empty
%           otherwise A's size must be equal to this param
%           An Inf value at any place in this param allows
%               for any size in that dimension
%
%   Example usages:
%       CheckNumericArraySize( A, [Inf 2] ) - i.e., no restrictions on dimension 1 and size 2 for dimension 2
%       CheckNumericArraySize( A, [Inf Inf] ) - for an MxN array
%       CheckNumericArraySize( A, [3 4 5]) - for a 3x4x5 array
%       CheckNumericArraySize( A, []) - for an empty array
%       Note, for instance, that CheckNumericArraySize( A, [Inf Inf] ) will fail if A has more than two dimensions 

% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
% Thanks to Jan Simon for pointing out simplifications and bugs
function CheckNumericArraySize( A, dim_sizes )
    if ~exist('A','var')
        error('This function needs an array as input');
    end  
    if ~isnumeric(A)
        error('Input is not a numeric array');
    end
    if ~exist('dim_sizes','var')
        return;
    end
    if ~isnumeric(dim_sizes)
        error('Second param needs to be a 1 * 2 array with the desired dimension sizes');
    end
    if isempty(dim_sizes)
        if isempty(A)
            return;
        else
             error('Array is not empty');
        end
    end
    if size(dim_sizes,1) ~= 1 || size(dim_sizes,2) < 2
        error('Second param ''desired_dims_sizes'' must be either an empty or a 1 * d array, d >= 2');
    end
    if ndims(A) ~= size(dim_sizes,2)
        error(['Array has ' num2str(ndims(A)) ' dimensions and it should have ' num2str(size(dim_sizes,2))]);
    end
    if ~all((size(A) == dim_sizes | isinf(dim_sizes)))
        % get formatted error strings for sizes
        sizes_A_str = get_formatted_error_string_size(size(A));
        sizes_dim_str = get_formatted_error_string_size(dim_sizes);
        error(['Array has size in each dimension ' sizes_A_str ' and it should have ' sizes_dim_str]);
    end
end

function error_str_size = get_formatted_error_string_size(size_)
    if isinf(size_(1))
        str = 'Any';
    else
        str = num2str(size_(1));
    end
    error_str_size = ['[' str];
    for i=2:size(size_,2)
        if isinf(size_(i))
            str = 'Any';
        else
            str = num2str(size_(i));
        end
        error_str_size = [error_str_size ' ' str];
    end
    error_str_size = [error_str_size ']'];
end