%Implemented as per Markus Schoeler's work in Bootstraping the semantics ..
%The principle is: if both of the displacementIJ and normalJ
%and displacementJI cross products are positive then the point pair is
%convex connected
%displacementIJ is representing the difference in each of the
%three dimensions of the two points (vector). To get displacementJI just
%negate dispalcementIJ
%normalI and normalJ are the normals at points I and J respectively.
function [isConvexConnected] = convexConnectedPair( displacementIJ, normalI, normalJ)
    if (displacementIJ * normalJ' > 0) && (-displacementIJ * normalI' > 0) 
        isConvexConnected = 1;
    else
        isConvexConnected = 0;
    end
end
