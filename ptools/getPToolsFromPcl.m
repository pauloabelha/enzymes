% Beginning function of pTools extraction. Starts from PCL and stocks pTools and pTools vectors.

% /!\ Need getTaskOrientationVectors execution before loading, and modify it if a new task wanna be added.
% task is a string

function [pTools, pTool_vecs, transfs_lists, P, SQs, ROT_FIT_ERRORSs, ROT_FIT_ORIG_ERRORS] = getPToolsFromPcl(path, pcl_name, tool_mass, task, fit_threshold, pTool_prefix, get_alt_SQ_Fits, write_file )

if ~exist('get_alt_SQ_Fits','var')
    get_alt_SQ_Fits = 0;
end

if ~exist('fit_threshold','var')
    fit_threshold = 1.5;
end

% get write argument
if ~exist('write_file','var')
    write_file=0;
end

if ~exist('pTool_prefix','var')
    pTool_prefix='';
end

% read pointcloud from file ( get only the first returned arg)
if ischar(path)
    P = ReadPointCloud(strcat(path,pcl_name));
else
    P = path;
end

if size(P.segms,2) < 2
    error(['Point cloud ' pcl_name ' has less than two good segments']);
end

%% SQ Fitting
[ swiss_cheese, P_cheeseless, SQs_cheeseless, ~, ~, ~, swiss_cheese_segm_labels ] = FitAndCheckSwissCheeseSegmentation( P, fit_threshold );
if swiss_cheese
    error(['Segmentation of ' pcl_name ' is too bad for pTool extraction to be reliable (possibly a swiss-cheese segmentation)']);
end

if size(P_cheeseless.segms,2) ~= size(P.segms,2)
    warning(['One or more swiss cheese segments were removed from ' pcl_name '. Fusing bad segments into good ones...']);
    P_cheeseless = FuseSegmIntoOthers( P, swiss_cheese_segm_labels(1), 1 );
end
P=P_cheeseless;

%SQs = PCL2SQ(segms,4,0,0,[1 1 1 0 1]);

if size(P.segms,2) < 2
    error(['Point cloud ' pcl_name ' has less than two good segments']);
end


%% pTool structs extraction from SQs
[alt_SQs_cheeseless,ROT_FIT_ERRORSs,ROT_FIT_ORIG_ERRORS] = GetRotationSQFits( SQs_cheeseless, P.segms, 0.1 );

SQs = cell(size(SQs_cheeseless,2),1);
for i=1:size(SQs_cheeseless,2)
    SQs{i}{1} = SQs_cheeseless{i};
end
if get_alt_SQ_Fits
    for i=1:size(alt_SQs_cheeseless,1)
        for j=1:size(alt_SQs_cheeseless{i},2)
            alt_SQ = alt_SQs_cheeseless{i}{j};
            if ~isempty(alt_SQ)
                SQs{i}{end+1} = alt_SQ;
            end
        end
    end
end

[ pTools, transfs_lists ] = ExtractPToolsSQs(SQs, tool_mass, 0, pTool_prefix);
% [pTools,transfs_lists] = ExtractPToolsAltSQs(SQs, tool_mass, task, pTool_prefix);


pTool_vecs = getVectors(pTools);

%% Save matrix in a file
if write_file
    fileName = strcat(path, '/pTools_vectors.txt');
    dlmwrite(fileName, pTool_vecs, 'delimiter', '\t');
    fileattrib(fileName,'+w','a');
end


end
