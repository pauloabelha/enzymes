%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
%
%% This function reads a CSV file containing non-/numeric values
% Inputs:
%   filepath - full path to file
% Outputs:
%   csv_values - values read from file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ csv_values ] = ReadCSVGeneric( filepath )   
    % try to read file from the specified path
    fid_output = fopen(filepath);
    if fid_output == -1
        error(['Could not open file ' filepath]);
    end
    % read each line form file, splitting the current line with ','
    % and adding the values into separate cell-columns in csv_values
    csv_values = {};
    ix=0;
    while ~feof(fid_output)
        ix = ix+1;
        line = fgetl(fid_output);
        line_split_values = strsplit(line,',');
        for split_col=1:size(line_split_values,2)
            csv_values{ix,split_col} = line_split_values{split_col};
        end   
    end
    try
        A = zeros(size(csv_values,1),size(csv_values,2));
        for i=1:size(csv_values,1)
            for j=1:size(csv_values,2)
                a = csv_values(i,j);
                A(i,j) = str2num(a{1});                 
            end
        end
        csv_values = A;
    catch
        warning('Could not convert cell array to matrix of numbers (buy maybe that wasn''t required?)');
    end
end

