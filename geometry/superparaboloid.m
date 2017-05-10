function [ output_args ] = superparaboloid( a1, a2, a3, eps1, eps2 )
    [ ~, us ] = superparabola( 1, a1, eps1 );
    [ ~, thetas ] = superellipse( a2, a3, eps2 );
    a=0;

end

