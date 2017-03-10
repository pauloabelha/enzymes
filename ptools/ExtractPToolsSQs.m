

% SQ_options is a 2-dim cell array (segments X fit options)

function [ pTools, transf_list, ixs, SQs ] = ExtractPToolsSQs(SQ_options, mass, alternate_grasp, prefix)
    
    if ~exist('alternate_grasp','var')
        alternate_grasp = 0;
    end

    if ~exist('prefix','var')
        prefix = '';
    end
    
    n_segments = size(SQ_options,1);
    assignments = nchoosek(1:n_segments,2);
    usage_assignments = zeros(size(assignments,1)*2,2);
    ix = 1;
    for i=1:size(assignments,1)
        usage_assignments(ix,:) = assignments(i,:);
        ix = ix + 1;
        usage_assignments(ix,:) = fliplr(assignments(i,:));
        ix = ix + 1;
    end
    % run through the usage assignments and extract one ptool for every
    % SQ fitting option
    pTools = {};
    transf_list = {};
    ixs = [];
    SQs_grasp = {};
    SQs_action = {};
    for usage_ix=1:size(usage_assignments,1)
        grasp_segm_ix = usage_assignments(usage_ix,1);
        action_segm_ix = usage_assignments(usage_ix,2);
        n_options_action = size(SQ_options{action_segm_ix},2);
        for action_fit_opt=1:n_options_action
            SQ_action_opt = SQ_options{action_segm_ix}{action_fit_opt}; 
            grasp_fit_opt = 1;
            if alternate_grasp                
                n_options_grasp = size(SQ_options{grasp_segm_ix},2);
                for grasp_fit_opt=1:n_options_grasp
                    ixs(end+1,:) = [grasp_segm_ix action_segm_ix grasp_fit_opt action_fit_opt];
                    SQ_grasp_opt = SQ_options{grasp_segm_ix}{grasp_fit_opt};
                    suffix = [num2str(grasp_fit_opt) num2str(action_fit_opt)];
                    [pTools{end+1},transf_list{end+1}] = ExtractPTool({SQ_grasp_opt,SQ_action_opt},mass,prefix,suffix);
                    SQs_grasp{end+1} = SQ_grasp_opt;
                    SQs_action{end+1} = SQ_action_opt;
                end
            else
                ixs(end+1,:) = [grasp_segm_ix action_segm_ix grasp_fit_opt action_fit_opt];
                SQ_grasp_opt = SQ_options{grasp_segm_ix}{grasp_fit_opt};
                suffix = [num2str(grasp_fit_opt) '_' num2str(action_fit_opt)];
                [pTools{end+1},transf_list{end+1}] = ExtractPTool({SQ_grasp_opt,SQ_action_opt},mass,prefix,suffix);
                SQs_grasp{end+1} = SQ_grasp_opt;
                SQs_action{end+1} = SQ_action_opt;
            end           
        end        
    end
    SQs = {SQs_grasp SQs_action};
end

