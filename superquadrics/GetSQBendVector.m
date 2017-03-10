function [ vec ] = GetSQBendVector( SQ )
    x_vec = GetSQVector(SQ,'x');
    rot_z = GetRotMtx(SQ(12),'z');
    vec = rot_z*x_vec;
end