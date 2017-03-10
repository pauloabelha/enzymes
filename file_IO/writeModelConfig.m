function [] = writeModelConfig(path)
	fid=fopen(strcat(path,'model.config'),'wt');
    fprintf(fid,'<?xml version="1.0"?>\n');
    fprintf(fid,'<model>\n<name>Tool</name>\n<version>1.0</version>\n<sdf version=''1.6''>tool.sdf</sdf>\n');
    fprintf(fid,'<author>\n<name>Paulo Abelha and Benjamin Nougier</name>\n<email>p.abelha@abdn.ac.uk</email>\n</author>\n');
    fprintf(fid,'<description>\nAutomatically generated from a pTool\n</description>\n</model>');
    fclose(fid);
end

