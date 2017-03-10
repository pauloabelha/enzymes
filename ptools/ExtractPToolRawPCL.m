%extracts ptools from a raw (unsegmented) pcl
function [ ptools, ptools_map, P, SQs, SQs_alt ] = ExtractPToolRawPCL( P, mass )
%     if numel(P.segms) < 2
%         segms = CutPCLDemocritus2(P.v, 0.005, 1);
%         for i=1:numel(segms)
%             P.segms{end+1}.v = segms;
%         end
%      
%     end
%     if numel(P.segms) < 2
%         error('Could not segment pcl');
%     end
    SQs = PCL2SQ( P, 1, 0, 0, [1 0 0 0 1] );
    % if there is only one segm, repeat SQ to create ptool
    segms = P.segms;
    if numel(P.segms) < 2
        SQs{end+1} = SQs{1};
        segms{1} = P.segms{1};
        segms{end+1} = P.segms{1};
    end
    SQs_alt = GetRotationSQFits( SQs, segms );
    [ptools, ptools_map] = ExtractPToolsAltSQs(SQs_alt, mass);
end

