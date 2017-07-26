%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
%
%% Displays the estimated time to finish a for loop
%
% Inputs:
%   tot_toc -   initial time spent so far
%   curr_ix -   current for loop index value
%   tot_iter -  for loop end index value
%   prefix -    prefix to be added to the output string
% Outputs:
%   tot_toc - output the input value so we can use it (see usage below)
%   estimated_time_hours - estimated time in hours (in case you need it)
%
% IMPORTANT: USAGE
% 
% % declare tot_toc as 0
% tot_toc = 0;
% for i=init_iter:tot_iter
%   % before anything, get tic
%   tic
%   % perform your computations
%   ...
%   % at the end, call this function like this:
%   tot_toc = DisplayEstimatedTimeOfLoop( tot_toc+toc, i, tot_iter-init_iter );
% end
%
% This way you are able to keep giving the function the current time spent
%
% Keep in mind Hofstadter's Law when using this function :)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ tot_toc, estimated_time_hours  ] = DisplayEstimatedTimeOfLoop( tot_toc, curr_ix, tot_iter, prefix )
    if ~exist('prefix','var')
        prefix = '';        
    end
    if curr_ix == tot_iter
        disp([prefix 'Total elapsed time (HH:MM:SS): ' datestr(tot_toc/(24*60*60),'HH:MM:SS')]);
    else
        avg_toc = tot_toc/curr_ix;
        estimated_time_hours = (avg_toc*(tot_iter-curr_ix))/(24*60*60);
        msg = [prefix 'Estimated time to finish (HH:MM:SS): ' datestr(estimated_time_hours, 'HH:MM:SS') ' ' num2str(round(curr_ix*100/tot_iter)) '%'];
        disp(msg);
    end
end