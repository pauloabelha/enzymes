%assuming ZYZ Euler Angles
function [ RotM ] = eul2rot_Paulo( angles )

ang1 = angles(1);
ang2 = angles(2);
ang3 = angles(3);

RotZ1 = [cos(ang1) -sin(ang1) 0; sin(ang1) cos(ang1) 0; 0 0 1];
RotY = [cos(ang2) 0 sin(ang2); 0 1 0; -sin(ang2) 0 cos(ang2)];
RotZ2 = [cos(ang3) -sin(ang3) 0; sin(ang3) cos(ang3) 0; 0 0 1];

RotM = RotZ1*RotY*RotZ2;

end

