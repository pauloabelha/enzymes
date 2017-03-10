function [] = writeWorldFile( path,task,modelName )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    fid=fopen((strcat(path,task,'.world')),'wt');
    fprintf(fid,'<?xml version=''1.0''?>\n');
    fprintf(fid,'<sdf version=''1.6''>\n');
    fprintf(fid,'<world name="Hammering">\n');
    fprintf(fid,'<include>\n<uri>model://ground_plane</uri>\n</include>\n');
    fprintf(fid,'<include>\n<uri>model://sun</uri>\n</include>\n');
    fprintf(fid,'<include>\n<uri>model://%s</uri>\n</include>\n',modelName);
    fprintf(fid,'<include>\n<uri>model://nail</uri>\n</include>\n</world></sdf>');
    fclose(fid);
end

