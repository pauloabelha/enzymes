function [ ptools, ptools_map, ptools_errors, ERRORS_SQs_alt, SQs_ptools, ERRORS_SQS] = ExtractPToolsAltSQs(SQs, mass, ERRORS_SQs_alt, grasp_alt, parallel)
    if ~exist('ERRORS_SQs_alt','var')
        ERRORS_SQs_alt = zeros(size(SQs,1),size(SQs,2)) + Inf;
    end
    if ~exist('grasp_alt','var')
        grasp_alt=0;
    end
    if ~exist('parallel','var')
        parallel=1;
    end
    ptools_map = [];
    SQs_ptools = {};
    ERRORS_SQS = {};
    SQs_1 = [];
    SQs_2 = [];
    ERRORS = [];
    for sq1_ix=1:size(SQs,2)
        n_grasp_alt = size(SQs,1);
        if ~grasp_alt
            n_grasp_alt=1;
        end
        for sq1_alt_ix=1:n_grasp_alt
            SQ1 = SQs{sq1_alt_ix,sq1_ix};
            if isempty(SQ1)
                continue;
            end
            for sq2_ix=1:size(SQs,2)
                for sq2_alt_ix=1:size(SQs,1)
                    if sq1_ix == sq2_ix
                        break;
                    end
                    SQ2 = SQs{sq2_alt_ix,sq2_ix};
                    if isempty(SQ2)
                        continue;
                    end 
                    SQs_1(end+1,:) = SQ1;
                    SQs_2(end+1,:) = SQ2;
                    SQs_ptools{end+1} = [SQ1; SQ2];
                    ERRORS_SQS{end+1} = [ERRORS_SQs_alt(sq1_alt_ix,sq1_ix); ERRORS_SQs_alt(sq2_alt_ix,sq2_ix)];
                    ERRORS(end+1) = ERRORS_SQs_alt(sq1_alt_ix,sq1_ix) + ERRORS_SQs_alt(sq2_alt_ix,sq2_ix);
                    ptools_map(end+1,:) = [SQ1(end-2:end) GetSQVector(SQ1)'];
                end
            end
        end
    end
    ptools = zeros(size(SQs_1,1),25);
    ptools_errors = zeros(1,size(ptools,1));
    if parallel
        parfor i=1:size(ptools,1)
            [ptools(i,:), ~, ~, ptools_errors(i)] = ExtractPTool(SQs_1(i,:),SQs_2(i,:),mass,ERRORS(i)); 
        end
    else
        for i=1:size(ptools,1)
            [ptools(i,:), ~, ~, ptools_errors(i)] = ExtractPTool(SQs_1(i,:),SQs_2(i,:),mass,ERRORS(i)); 
        end
    end
    
end