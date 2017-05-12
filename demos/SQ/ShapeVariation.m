function [ SQs ] = ShapeVariation(  )
    
    for eps1=.1:.5:2
        for eps2=.1:.5:2
            
            pcl = superellipsoid( [1 1 1 eps1 eps2] );
        end
    end


end

