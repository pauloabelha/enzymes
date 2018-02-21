function tests = MOITest
    tests = functiontests(localfunctions);
end

% test for sphere of radius 1 and mass 1
function testSphere(testCase)
    mass = 1;
    radius = 1;
    test_SQ = [radius radius radius 1 1 0 0 0 0 0 0 0 0 0 0];
    I = CalcCompositeMomentInertia( test_SQ, mass);  
    % expected Ixx in SI (standard units)
    expI_xx = (2/5)*mass*radius^2;
    verifyEqual(testCase,I(1,1),expI_xx,'AbsTol',1e-10);
    verifyEqual(testCase,I(1,1),I(2,2),'AbsTol',1e-10);
    verifyEqual(testCase,I(1,1),I(3,3),'AbsTol',1e-10);
end

% test for sphere of radius 1 and mass 1
function testSmallSphere(testCase)    
    mass = .0001;
    radius = .0001;
    ERROR_TOL = mass*radius^2*1e-1;
    test_SQ = [radius radius radius 1 1 0 0 0 0 0 0 0 0 0 0];
    I = CalcCompositeMomentInertia( test_SQ, mass);  
    % expected Ixx in SI (standard units)
    expI_xx = (2/5)*mass*radius^2;
    verifyEqual(testCase,I(1,1),expI_xx,'AbsTol',ERROR_TOL);
    verifyEqual(testCase,I(1,1),I(2,2),'AbsTol',ERROR_TOL);
    verifyEqual(testCase,I(1,1),I(3,3),'AbsTol',ERROR_TOL);
end

% test for sphere of radius 1 and mass 1
function testLargeSphere(testCase)    
    mass = 1000;
    radius = 1000;
    ERROR_TOL = mass*radius^2*1e-1;
    test_SQ = [radius radius radius 1 1 0 0 0 0 0 0 0 0 0 0];
    I = CalcCompositeMomentInertia( test_SQ, mass);  
    % expected Ixx in SI (standard units)
    expI_xx = (2/5)*mass*radius^2;
    verifyEqual(testCase,I(1,1),expI_xx,'AbsTol',ERROR_TOL);
    verifyEqual(testCase,I(1,1),I(2,2),'AbsTol',ERROR_TOL);
    verifyEqual(testCase,I(1,1),I(3,3),'AbsTol',ERROR_TOL);
end

% test for spherical ellipsoid of radii 1, 2, 3 and mass 3
function testSphericalEllipsoid(testCase)
    mass = 3;
    a = 1; b = 2; c = 3;
    test_SQ = [a b c 1 1 0 0 0 0 0 0 0 0 0 0];
    volume = VolumeSQ(test_SQ);
    density = mass / volume;    
    I = CalcCompositeMomentInertia( test_SQ, mass); 
    expI_xx = (4*pi/15)*a*b*c*(b^2+c^2)*density;
    verifyEqual(testCase,I(1,1),expI_xx,'AbsTol',1e-10);
    expI_yy = (4*pi/15)*a*b*c*(a^2+c^2)*density;
    verifyEqual(testCase,I(2,2),expI_yy,'AbsTol',1e-10);
    expI_zz = (4*pi/15)*a*b*c*(a^2+b^2)*density;
    verifyEqual(testCase,I(3,3),expI_zz,'AbsTol',1e-10);
end

% test for cube of side 1 and mass 1
function testCube(testCase)
    mass = 1;
    side1 = 1; side2 = 1; side3 = 1;
    test_SQ = [side1/2 side2/2 side3/2 1e-10 1e-10 0 0 0 0 0 0 0 0 0 0];
    I = CalcCompositeMomentInertia(test_SQ, mass);   
    % expected I in SI (standard units)
    expI = zeros(3,3);
    expI(1,1) = (1/12)*mass*(side2^2+side3^2);  
    expI(2,2) = (1/12)*mass*(side1^2+side3^2);
    expI(3,3) = (1/12)*mass*(side1^2+side2^2); 
    verifyEqual(testCase,I,expI,'AbsTol',1e-10);
end

% test for cuboid of size 1 2, 3 and mass 2
function testCuboid(testCase)
    mass = 2;
    side1 = 1; side2 = 2; side3 = 3;
    test_SQ = [side1/2 side2/2 side3/2 1e-10 1e-10 0 0 0 0 0 0 0 0 0 0];
    I = CalcCompositeMomentInertia(test_SQ, mass);   
    % expected I in SI (standard units)
    expI = zeros(3,3);
    expI(1,1) = (1/12)*mass*(side2^2+side3^2);  
    expI(2,2) = (1/12)*mass*(side1^2+side3^2);
    expI(3,3) = (1/12)*mass*(side1^2+side2^2); 
    verifyEqual(testCase,I,expI,'AbsTol',1e-10);
end

